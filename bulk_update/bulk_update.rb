require 'intercom'
require 'retries'
require 'redis'

# Initialize the Intercom client
intercom = Intercom::Client.new(token: ENV['TEST_PAT'])
MAX_RETRIES = 3
SCROLL_RESET_TIME = 60
scroll_num = 0
# Set scroll param to nil initially and then populate with returned parameter
scroll_param = nil
count=1
# Create new instance that you can use to store IDs
$redis = Redis.new

def check_attrib(attrib)
  # Check each user to see if they have set their Avatar
  if attrib.nil?
    custom_attribs = {
        :'has avatar' => false
    }
  else
    custom_attribs = {
        :'has avatar' => true
    }
  end
  return(custom_attribs)
end

def redis_store(job_id)
  time = Time.new
  time_key = time.day.to_s + time.hour.to_s + time.min.to_s
  begin
    $redis.sadd(time_key, job_id)
  rescue Redis::CannotConnectError => error
    # Redis is not available so output ID and error
    puts("job_id=#{job_id} error=#{error.message}")
  end
end

# Create a handler to be called each time your block of code is retried
handler = Proc.new do |exception, attempt_number, total_delay|
  puts "Handler saw a #{exception.class}: #{exception.message}; retry attempt #{attempt_number}; #{total_delay} seconds have passed."
  if /scroll already exists/.match(exception.message) || /scroll parameter not found/.match(exception.message)
    # If the scroll already exists, or it is not found the reset and start again
    scroll_param = nil
    # If you have made a recent request with this scroll param then you will need to wait
    # 60 seconds to start again with your new scroll request
    sleep(SCROLL_RESET_TIME)
  end
end

begin
  with_retries(:max_tries => MAX_RETRIES, :handler => handler,
               :rescue => [Intercom::RateLimitExceeded,
                           Intercom::UnexpectedError,
                           Intercom::ResourceNotFound]) do |attempt|
    # You can check for the max retry number and raise an error so you can take some action based on this event
    raise("No longer retrying since we have retried #{attempt} times.\n") if attempt >= MAX_RETRIES

    result = intercom.users.scroll.next(scroll_param)
    all_users = []
    result.records.each do |user|
      user_data = {}
      cus_attr = check_attrib(user.avatar.image_url)
      # We need a unique identifer (email, id or user_id) to update the user
      user_data[:id] = user.id
      # Create/update the user with a custom attribute
      user_data[:custom_attributes] = cus_attr
      #Put it all in an array so we can bulk create it when it reaches 100
      all_users << user_data
    end
    scroll_num = result.records.length
    scroll_param = result.scroll_param
    # Check to see if the most recent request is empty (no more users to update)
    if scroll_num > 0
      bulk = intercom.users.submit_bulk_job(create_items: all_users)
      puts("Bulk Request Number #{count}")
      redis_store(bulk.id)
      puts(bulk.id)
      count+=1
    end
  end
end while scroll_num > 0

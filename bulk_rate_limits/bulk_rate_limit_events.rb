require 'intercom'

intercom = Intercom::Client.new(token: ENV['PROD_PAT'])

retries = 0
max_retries = 3
backoff_factor = 2
scroll_param = nil
count=1
SCROLL_RESET_TIME = 60
event_count = 0

def print_rate_headers(client)
  puts("Rate Limit: #{client.rate_limit_details[:limit]} \n")
  puts("Remaining: #{client.rate_limit_details[:remaining]} \n")
  puts("Reset Time: #{client.rate_limit_details[:reset_at]} \n")
end

def print_error_info(err)
  puts("Error Msg: #{err.inspect} \n")
  puts("http_code: #{err.http_code[:http_code]}\n" )
  puts("http_code: #{err.http_code[:application_error_code]}\n" )
end

for num in 0..5
  begin
    puts("Request Number #{num+1}")
    result = intercom.users.scroll.next(scroll_param)
    update_time = {
        :'update time' => Time.now
    }
    all_events = []
    result.records.each_with_index do |user, i|
      event_data = {}
      # We need a unique identifer (email, id or user_id) to update the user
      event_data[:id] = user.id
      # Create/update the event with a name and some metadata
      event_data[:event_name] = "bulk-rate-test"
      event_data[:metadata] = update_time
      #Put it all in an array so we can perform bulk update
      all_events << event_data
      event_count = i
      puts(event_data)
      break if i==0
    end
    puts("Number of events #{event_count} \n")
    scroll_num = result.records.length
    scroll_param = result.scroll_param
    # Check to see if the most recent request is empty (no more users to update)
    exit unless  scroll_num > 0
    bulk = intercom.events.submit_bulk_job(create_items: all_events)
    print_rate_headers(intercom)
    puts("Bulk Request Number #{count}")
    puts(bulk.id)
    count+=1

  rescue Intercom::RateLimitExceeded => error
    # At this point we know we have encountered a limit
    # So lets try for a few times and backoff a little in each case
    print_error_info(error)
    if retries <= max_retries
      # Lets try it a few more times
      retries += 1
      puts("Backoff for #{backoff_factor * retries} seconds")
      sleep backoff_factor * retries
    else
      # Rasing error here so you can perform some action based on this event
      raise("No longer retrying since we have retried #{retries} time.\n"\
              "The error returned was: '#{error.message}'")
    end
  rescue => error
    print_error_info(error)
    if /scroll already exists/.match(error.inspect) || /scroll parameter not found/.match(error.inspect)
      # If the scroll already exists, or it is not found the reset and start again
      scroll_param = nil
      puts("RESETTING SCROLL")
      # If you have made a recent request with this scroll param then you will need to wait
      # 60 seconds to start again with your new scroll request
      sleep(SCROLL_RESET_TIME)
    else
      raise("Received a general error so exiting: #{error}")
    end
  end
end
require 'intercom'
require 'retries'

intercom = Intercom::Client.new(token: ENV['TEST_PAT'])
max_retries = 3

for num in 0..20
  # Create a handler to be called each time the your block of code is retried
  handler = Proc.new do |exception, attempt_number, total_delay|
    puts "Handler saw a #{exception.class}; retry attempt #{attempt_number}; #{total_delay} seconds have passed."
  end
  with_retries(:max_tries => max_retries, :handler => handler, :rescue => [Intercom::RateLimitExceeded]) do |attempt|
    puts("Request Number #{num+1}")
    # You can check for the max retry number and raise an error so you can take some action based on this event
    if attempt >= max_retries
      raise("No longer retrying since we have retried #{attempt} time.\n"\
    "The error returned was: '#{Intercom::RateLimitExceeded}'")
    end
    email = 'user' + num.to_s + '@limit.com'
    name = 'Mr ' + num.to_s + "Limit"
    # Make a HTTP POST request to Intercom to create/update a user
    response = intercom.users.create(:email => email, :name => name, :signed_up_at => Time.now.to_i)
  end

end

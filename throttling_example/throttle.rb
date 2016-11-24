require 'intercom'

intercom = Intercom::Client.new(token: ENV['TEST_PAT'])

retries = 0
max_retries = 3
backoff_factor = 2

for num in 0..20
  begin
    puts("Request Number #{num+1}")
    email = 'user' + num.to_s + '@limit.com'
    name = 'Mr ' + num.to_s + "Limit"
    response = intercom.users.create(:email => email, :name => name, :signed_up_at => Time.now.to_i)
    puts("Rate Limit: #{intercom.rate_limit_details[:limit]} \n")
    puts("Remaining: #{intercom.rate_limit_details[:remaining]} \n")
    puts("Reset Time: #{intercom.rate_limit_details[:reset_at]} \n")

  rescue Intercom::RateLimitExceeded => error
    # At this point we know we have encountered a limit
    # So lets try for a few times and backoff a little in each case
    puts("Error Msg: #{error.inspect} \n")
    puts("http_code: #{error.http_code[:http_code]}\n" )
    puts("http_code: #{error.http_code[:application_error_code]}\n" )

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
    raise("Received a general error so exiting: #{error}")
  end
end
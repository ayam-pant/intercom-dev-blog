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
    # Make a HTTP POST request to Intercom to create/update a user
    response = intercom.users.create(:email => email, :name => name, :signed_up_at => Time.now.to_i)
    # These are the headers we have access to when making requests
    puts("Rate Limit: #{intercom.rate_limit_details[:limit]} \n")
    puts("Remaining: #{intercom.rate_limit_details[:remaining]} \n")
    puts("Reset Time: #{intercom.rate_limit_details[:reset_at]} \n")

    # Check when request limit is under a certain number
    if not intercom.rate_limit_details[:remaining].nil? and intercom.rate_limit_details[:remaining] < 2
      sleep_time = intercom.rate_limit_details[:reset_at].to_i - Time.now.to_i
      puts("Waiting for #{sleep_time} seconds to allow for rate limit to be reset")
      sleep sleep_time
    end
  rescue => error
    raise("Received a general error so exiting: #{error}")
  end
end
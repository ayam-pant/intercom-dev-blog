require 'json'
require 'intercom'
require 'json'

class ConvoParser
  attr_reader :intercom

  def initialize(client)
    @intercom = client
  end

  def print_output(content)
    puts(content)
  end

  def parse_convos(payload, attr)
    puts JSON.pretty_generate(payload[attr])
  end

  def parse_single_convo(convo)
    puts "<XXXXXXXXXXXXX CONVERSATION XXXXXXXXXXXXX>"
    puts JSON.pretty_generate(convo)
    puts "<XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX>"
  end
end

class ConvoSetup
  attr_reader :intercom, :convo_parser

  def initialize(access_token)
    # You should alwasy store you access token in a environment variable
    # This ensures you never accidentally expose it in your code
    @intercom = Intercom::Client.new(token: ENV[access_token])
    @convo_parser = ConvoParser.new(intercom)
  end

  def get_all_conversations(client)
    # Get the first page of your conversations
    convos = client.get("/conversations", "")
    convos
  end

  def run
    result = get_all_conversations(intercom)
    # Parse through each conversation to see what is provided via the list
    result["conversations"].each do |single_convo|
      convo_parser.parse_single_convo(single_convo)
    end

  end
end

ConvoSetup.new("AT").run
require 'json'
require 'intercom'
require 'json'

class ConvoParser
  attr_reader :intercom

  def initialize(client)
    @intercom = client
  end

  def parse_single_convo(convo)
    puts "<XXXXXXXXXXXXX CONVERSATION XXXXXXXXXXXXX>"
    puts JSON.pretty_generate(convo)
    puts "<XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX>"
  end

  def parse_conversation_part(convo_part)
    puts "<XXXXXXXXXX CONVERSATION PARTS XXXXXXXXXX>"
    puts "PART ID: #{convo_part.id}"
    puts "PART TYPE: #{convo_part.part_type}"
    puts "PART BODY: #{convo_part.body}"
    puts "<XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX>"
  end

  def parse_conversation_parts(convo)
    total_count = convo.conversation_parts.length
    current_count = 0
    puts "FIRST MSG: #{convo.conversation_message}"
    puts "NUM PARTS: #{total_count}"
    convo.conversation_parts.each do |convo_part|
      puts "PART #{current_count+=1} OF #{total_count}"
      parse_conversation_part(convo_part)
    end
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

  def get_single_convo(convo_id)
    # Get a single conversation
    intercom.conversations.find(id: convo_id)
  end

  def get_all_conversations
    # Get the first page of your conversations
    convos = intercom.get("/conversations", "")
    convos
  end

  def run
    # Get list of all conversations
    result = get_all_conversations

    # Parse through each conversation to see what is provided via the list
    result["conversations"].each do |single_convo|
      convo_parser.parse_conversation_parts(get_single_convo(single_convo['id']))
    end

  end
end

ConvoSetup.new("AT").run
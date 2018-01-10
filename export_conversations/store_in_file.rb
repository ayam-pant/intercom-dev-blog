require 'json'
require 'intercom'
require 'json'

class ConvoParser
  attr_reader :intercom, :output_file

  def initialize(client, file_name)
    @intercom = client
    @output_file = file_name

    File.write(file_name, "")
  end

  def write_to_file(content)
    File.open(output_file, 'a+') do |f|
      f.puts(content.to_s + "\n")
    end
  end

  def parse_single_convo(convo)
    puts "<XXXXXXXXXXXXX CONVERSATION XXXXXXXXXXXXX>"
    puts JSON.pretty_generate(convo)
    puts "<XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX>"
  end

  def parse_conversation_part(convo_part)
    write_to_file("<XXXXXXXXXX CONVERSATION PARTS XXXXXXXXXX>")
    write_to_file("PART ID: #{convo_part.id}")
    write_to_file("PART TYPE: #{convo_part.part_type}")
    write_to_file("PART BODY: #{convo_part.body}")
    write_to_file("<XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX>")
  end

  def parse_conversation_parts(convo)
    total_count = convo.conversation_parts.length
    current_count = 0
    write_to_file("CONVO ID: #{convo.id}")
    write_to_file("NUM PARTS: #{total_count}")
    convo.conversation_parts.each do |convo_part|
      write_to_file("PART #{current_count+=1} OF #{total_count}")
      parse_conversation_part(convo_part)
    end
  end

end

class ConvoSetup
  attr_reader :intercom, :convo_parser

  def initialize(access_token, file_name)
    # You should alwasy store you access token in a environment variable
    # This ensures you never accidentally expose it in your code
    @intercom = Intercom::Client.new(token: ENV[access_token])
    @convo_parser = ConvoParser.new(intercom, file_name)
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

ConvoSetup.new("AT", "convo_output.txt").run
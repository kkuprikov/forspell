require 'yard'

class RubyDocLoader
  attr_reader :result

  def initialize file: nil
    fail "#{ self.class } could not find a file #{ file }" unless file
    @file = file
  end

  def process
    @result = []
    comments = YARD::Parser::Ruby::RubyParser.new(File.read(@file), @file)
    .parse.tokens.select{ |token| token.first == :comment }
    # example: [:comment, "# def loader_class path\n", [85, 2356]]

    @inputs = []
    comments.each do |comment|
      paragraph = @inputs.find{ |i| i[:end] == comment.last.first }
      if paragraph 
        @inputs.delete(paragraph)
        paragraph[:end] = comment.last.first + 1
        paragraph[:text] << comment[1]
      else
        @inputs << { start: comment.last.first, end: comment.last.first + 1, text: comment[1] }
      end
    end

    @inputs.map do |input|
      input[:parsed] = MarkdownLoader.new(input: input[:text]).process.result
      input
    end

    @inputs.each do |input|
      input[:parsed].each do |parsed_part|
        @result << {
          file: @file,
          location: input[:start] + parsed_part[:location],
          words: parsed_part[:words]
        }
      end
    end

    self
  end
end
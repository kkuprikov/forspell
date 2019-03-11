# frozen_string_literal: true

require 'yard'

module Forspell::Loaders
  class Ruby < Base
    def initialize(file: nil)
      super
      @parser_class = YARD::Parser::Ruby::RubyParser
    end

    def load_comments
      @parser_class.new(@input, @file).parse
                   .tokens.select { |token| token.first == :comment }
    rescue YARD::Parser::ParserSyntaxError, RuntimeError => e
      raise Forspell::Loader::ParsingError, e.message
      # example: [:comment, "# def loader_class path\n", [85, 2356]]
    end

    def load_words
      inputs = []

      load_comments.each do |comment|
        paragraph = inputs.find { |i| i[:end] == comment.last.first }
        if paragraph
          inputs.delete(paragraph)
          paragraph[:end] = comment.last.first + 1
          paragraph[:text] << comment[1]
          inputs << paragraph
        else
          inputs << { start: comment.last.first, end: comment.last.first + 1, text: comment[1] }
        end
      end

      inputs.map do |input|
        input[:parsed] = Markdown.new(input: input[:text]).process.result
        input
      end

      inputs.each do |input|
        input[:parsed].each do |parsed_part|
          location = input[:start].to_i + parsed_part[:line].to_i
          location -= 1 if input[:start] && parsed_part[:line]

          @result << Word.new(@file, location, parsed_part[:text])
        end

        next if input[:parsed]

        @errors << {
          file: @file,
          location: location,
          parsing_error: true
        }
      end

      self
    rescue RuntimeError => e
      raise Forspell::Reader::ParsingError, e.message
    end
  end
end

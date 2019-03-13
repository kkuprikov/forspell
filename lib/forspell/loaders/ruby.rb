# frozen_string_literal: true

require 'yard'

module Forspell::Loaders
  class Ruby < Base
    private def extract_words
      YARD::Parser::Ruby::RubyParser.new(@input, @file).parse.tokens
                   .select { |(type, _)| type == :comment }
                   .flat_map do |_, text, (start, _fin)|
        Markdown.new(text: text).read
                .map do |word|
                  word.file = @file
                  word.line += start - 1
                  word
                end
      end
    rescue YARD::Parser::ParserSyntaxError, RuntimeError => e
      raise Forspell::Loaders::ParsingError, e.message
    end
  end
end

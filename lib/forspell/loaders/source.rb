# frozen_string_literal: true

require 'yard'
module Forspell::Loaders
  class Source < Base
    COMMENT_METHODS = %i[source docstring].freeze

    private

    def extract_words
      parser = self.class.to_s.split('::').last.downcase.to_sym
      parsed = YARD.parse_string(@input, parser)
      raise ParsingError if parsed == true

      parsed.enumerator.flat_map do |comment|
        Markdown.new(text: text(comment)).read
                .map do |word|
                  word.file = @file
                  word.line += comment.line - 1
                  word
                end
      end
    end

    def text(comment)
      (comment.public_methods & COMMENT_METHODS).map do |method|
        comment.public_send method
      end.compact.first
    end
  end
end

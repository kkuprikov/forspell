# frozen_string_literal: true

require 'yard'
module Forspell::Loaders
  class Source < Base
    private

    def extract_words
      comments.flat_map do |comment|
        Markdown.new(text: text(comment)).read
                .map do |word|
                  word.file = @file
                  word.line += comment.line - 1
                  word
                end
      end
    end
  end
end

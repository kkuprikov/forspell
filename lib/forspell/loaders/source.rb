# frozen_string_literal: true

require 'yard'
require_relative 'base'
require_relative 'markdown'

module Forspell
  module Loaders
    class Source < Base
      private

      def extract_words
        comments.flat_map do |comment|
          Markdown.new(text: text(comment)).read
                  .map do |word|
                    word.file = @file
                    word.line += line(comment) - 1
                    word
                  end
        end
      end
    end
  end
end

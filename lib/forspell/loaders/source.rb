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

      def comments
        res = YARD::Registry.load([@file], true)
          .grep(YARD::CodeObjects::MethodObject)
          .flat_map do |code_object|
            comments = code_object.docstring.split(/\n/)
            if code_object.docstring.line_range
              code_object.docstring.line_range.each_with_index
                .map{|line, index| [line, comments[index]] if comments[index]}
            else
              nil
            end
          end.compact
        YARD::Registry.clear
        res
      end

      def text(comment)
        comment.last
      end

      def line(comment)
        comment.first
      end
    end
  end
end

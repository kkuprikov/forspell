# frozen_string_literal: true

require 'yard'
require 'yard/parser/ruby/ruby_parser'
require_relative 'source'

module Forspell::Loaders
  class Ruby < Source
    private

    def comments
      YARD::Parser::Ruby::RubyParser.new(@input, @file).parse
        .tokens.select{ |token| token.first == :comment }
        .reject{ |token| token[1].start_with?(/#\s{2,}/) }
      # example: [:comment, "# def loader_class path\n", [85, 2356]]
    end

    def text(comment)
      comment[1]
    end

    def line(comment)
      comment.last.first
    end
  end
end

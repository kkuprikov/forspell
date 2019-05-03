# frozen_string_literal: true

require 'yard'
require 'yard/parser/ruby/ruby_parser'
require_relative 'source'

module Forspell::Loaders
  class Ruby < Source
    private

    def comments
      YARD::Parser::Ruby::RubyParser.new(@input, @file).parse
        .tokens.select{ |type,| type == :comment }
        .reject{ |_, text,| text.start_with?('#  ') }
    end

    def text(comment)
      comment[1]
    end

    def line(comment)
      comment.last.first
    end
  end
end

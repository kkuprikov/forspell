# frozen_string_literal: true

require 'yard'
require 'yard/parser/ruby/ruby_parser'
require 'rdoc'
require_relative 'source'

module Forspell::Loaders
  class Ruby < Source
    MAX_COMMENT_LENGTH = 777
    
    def initialize(file: nil, text: nil)
      super
      @markup = RDoc::Markup.new
      @formatter = RDoc::Markup::ToMarkdown.new
      @formatter.width = MAX_COMMENT_LENGTH
    end

    private

    def comments
      YARD::Parser::Ruby::RubyParser.new(@input, @file).parse
        .tokens.select{ |type,| type == :comment }
        .reject{ |_, text,| text.start_with?('#  ') }
    end

    def text(comment)
      @markup.convert(comment[1], @formatter)
    end

    def line(comment)
      comment.last.first
    end
  end
end

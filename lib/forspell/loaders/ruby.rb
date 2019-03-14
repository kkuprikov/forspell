# frozen_string_literal: true

require 'yard'
require 'yard/parser/ruby/ruby_parser'
require_relative 'source'

module Forspell::Loaders
  class Ruby < Source
    private

    def comments
      YARD::Parser::Ruby::RipperParser.new(@input, @file).parse.enumerator
        .grep(YARD::Parser::Ruby::CommentNode)
    end

    def text(comment)
      comment.docstring
    end
  end
end

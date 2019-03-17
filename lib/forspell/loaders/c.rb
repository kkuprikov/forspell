# frozen_string_literal: true
require_relative 'source'

module Forspell::Loaders
  class C < Source
    def input
      res = super
      res.encode('UTF-8', invalid: :replace, replace: '?') unless res.valid_encoding?
      res
    end

    private

    def comments
      YARD::Parser::C::CParser.new(@input, @file).parse
        .grep(YARD::Parser::C::Comment)
    end

    def text(comment)
      comment.source
    end

    def line(comment)
      comment.line
    end
  end
end

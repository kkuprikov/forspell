# frozen_string_literal: true

module Forspell::Loaders
  class C < Base
    def input
      res = super
      res.encode('UTF-8', invalid: :replace, replace: '?') unless res.valid_encoding?
      res
    end

    private

    def extract_words
      YARD::Parser::C::CParser.new(@input, @file).parse
                              .grep(YARD::Parser::C::Comment)
                              .flat_map do |comment|
        Markdown.new(text: comment.source).read
                .map do |word|
                  word.file = @file
                  word.line += comment.line - 1
                  word
                end
      end
    end
  end
end

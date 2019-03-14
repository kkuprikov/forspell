# frozen_string_literal: true

require_relative '../sanitizer'

module Forspell::Loaders
  class Base
    include Forspell::Sanitizer
    Word = Struct.new(:file, :line, :text)

    WORD = %r{^
      \'?                      # could start with apostrophe
      ([[:upper:]]|[[:lower]]) # at least one letter,
      (
        ([[:lower:]])*   # then any number of letters,
        ([\'\-])?        # optional dash/apostrophe,
        [[:lower:]]*     # another bunch of letters
      )?
      \'?                # and finally, could end with apostrophe
    $}x


    def initialize(file: nil, text: nil)
      @file = file
      @input = text || input
      @words = []
      @errors = []
    end

    def read
      extract_words.each { |word| word.text = sanitize(word.text) }
                   .select{ |word| WORD.match(word.text) }
                   .reject { |w| w.text.nil? || w.text.empty? }
    rescue YARD::Parser::ParserSyntaxError, RuntimeError => e
      raise Forspell::Loaders::ParsingError, e.message
    end

    private

    def input
      File.read(@file)
    end

    def extract_words
      raise NotImplementedError
    end
  end
end

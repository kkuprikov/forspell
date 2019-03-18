# frozen_string_literal: true

require_relative '../sanitizer'
require_relative '../word_matcher'

module Forspell::Loaders
  Word = Struct.new(:file, :line, :text)
  
  class Base

    def initialize(file: nil, text: nil)
      @file = file
      @input = text || input
      @words = []
      @errors = []
    end

    def read
      extract_words.each { |word| word.text = Forspell::Sanitizer.sanitize(word.text) }
                   .select{ |word| Forspell::WordMatcher.word?(word.text) }
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

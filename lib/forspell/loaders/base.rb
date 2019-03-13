# frozen_string_literal: true

require_relative '../code_objects_filter'

module Forspell::Loaders
  class Base
    attr_reader :words, :errors

    include Forspell::CodeObjectsFilter
    Word = Struct.new(:file, :line, :text)

    def initialize(file: nil, text: nil)
      @file = file
      @input = text || input
      @words = []
      @errors = []
    end

    def read
      process
      @words
    end

    private

    def process
      @words = extract_words.each { |word| word.text = filter_code_objects(word.text) }
                            .reject { |w| w.text.nil? || w.text.empty? }
      @words
    end

    def input
      File.read(@file)
    end

    def extract_words
      raise NotImplementedError
    end
  end
end

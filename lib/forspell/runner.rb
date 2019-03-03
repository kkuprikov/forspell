# frozen_string_literal: true

require_relative 'reader'

module Forspell
  class Runner
    def initialize(files:, speller:, reporter:)
      @files = files
      @speller = speller
      @reporter = reporter
    end

    def call
      @files.each do |path|
        process_file path
      end

      @reporter.report

      self
    end

    private

    def process_file path
      @reporter.file(path)
      reader = Reader.new.for(path)
      begin
        words = reader.read
      rescue Forspell::Reader::ParsingError => e
        @reporter.parsing_error(e) and return
      end

      words.reject { |word| @speller.correct?(word.text) }
           .each { |word| @reporter.error(word, @speller.suggest(word.text)) }
    end
  end
end

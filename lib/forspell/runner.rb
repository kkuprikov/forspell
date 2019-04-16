# frozen_string_literal: true
require_relative 'loaders'

module Forspell
  class Runner
    def initialize(files:, speller:, reporter:, progress_bar:)
      @files = files
      @speller = speller
      @reporter = reporter
      @progress_bar = progress_bar
    end

    def call
      increment = (@files.size / 100.0).ceil

      @files.each_with_index do |path, index|
        process_file path
        @progress_bar.increment if index % increment == 0
      end

      @reporter.report

      self
    end

    private

    def process_file path
      @reporter.file(path) 
      
      words = Loaders.for(path).read
      words.reject { |word| @speller.correct?(word.text) }
           .each { |word| @reporter.error(word, @speller.suggest(word.text)) }
  
    rescue Forspell::Loaders::ParsingError => e
      @reporter.parsing_error(e) and return
    end
  end
end

# frozen_string_literal: true
require_relative 'loaders'

module Forspell
  class Runner
    def initialize(files:, speller:, reporter:)
      @files = files
      @speller = speller
      @reporter = reporter
    end

    def call
      increment = (@files.size / 100.0).ceil
      total = @files.size <= 100 ? @files.size : 100
      @reporter.progress_bar = ProgressBar.create(total: total, output: $stderr)

      @files.each_with_index do |path, index|
        process_file path
        @reporter.progress_bar.increment if (index + 1) % increment == 0
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

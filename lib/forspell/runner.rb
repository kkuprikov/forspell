# frozen_string_literal: true

require_relative 'reader'
require_relative 'loaders/file_loader'

module Forspell
  class Runner
    attr_reader :result, :total_errors

    def initialize(
      # dictionary_name: 'en_US',
      # logfile: nil,
      files:,
      # custom_dictionaries:,
      # verbose: false,
      # format: 'readable',
      # group: false
      speller:,
      reporter:
    )

      @files = files
      # @format = format
      # @verbose = verbose
      # @group = group

      # @speller = Speller.new(dictionary_name: dictionary_name,
      #                        custom_dictionaries: custom_dictionaries)
      # @reporter = Reporter.new(logfile: logfile,
      #                          verbose: verbose,
      #                          format: format,
      #                          group: group)
      @speller = speller
      @reporter = reporter
    end

    def call
      parsing_errors = []

      @files.each do |path|
        @reporter.file(path)
        reader = Reader.new.for(path)
        words = reader.read
        errors = reader.parsing_errors || []
        parsing_errors += errors unless errors.empty?
        words.each do |word|
          @reporter.error(word, @speller.suggest(word.text)) unless @speller.correct?(word.text)
        end
      end

      @reporter.report(parsing_errors, @files.size)
      @total_errors = @reporter.total_errors

      self
    end
  end
end

# frozen_string_literal: true

require 'json'
require_relative 'reader'
require_relative 'speller'
require_relative 'reporter'

class Forspell
  attr_reader :result, :total_errors

  def initialize(
    dictionary_name: 'en_US',
    logfile: nil,
    paths: nil,
    exclude_paths: [],
    include_paths: [],
    custom_dictionary_paths: nil,
    ruby_dictionary_path: "#{__FILE__.split('/')[0..-2].join('/')}/ruby.dict",
    verbose: false,
    format: 'readable',
    group: false
  )

    @paths = paths.is_a?(Array) ? paths : [paths]
    @format = format
    @verbose = verbose
    @group = group
    @include_paths = include_paths || []
    @exclude_paths = exclude_paths || []

    @speller = Speller.new(dictionary_name: dictionary_name,
                           custom_dictionary_paths: custom_dictionary_paths,
                           ruby_dictionary_path: ruby_dictionary_path)
    @reporter = Reporter.new(logfile: logfile,
                             verbose: verbose,
                             format: format,
                             group: group)
  end

  def process
    parsing_errors = []

    files.each do |path|
      @reporter.file(path)
      reader = Reader.new.for(path)
      words = reader.read
      errors = reader.parsing_errors || []
      parsing_errors += errors unless errors.empty?

      words.each do |word|
        @reporter.error(word, @speller.suggest(word.text)) unless @speller.correct?(word.text)
      end
    end

    @reporter.report(parsing_errors, files.size)
    @total_errors = @reporter.total_errors

    self
  end

  private

  def files
    @paths.map do |path|
      if File.extname(path).empty?
        FileLoader.new(path: path, include_paths: @include_paths, exclude_paths: @exclude_paths)
          .process.result
      else
        [path]
      end
    end.reduce(:+)
  end
end

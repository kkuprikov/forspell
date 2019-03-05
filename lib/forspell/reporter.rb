# frozen_string_literal: true

require 'fileutils'
require 'pastel'
require 'logger'
require 'json'

module Forspell
  class Reporter
    SUCCESS_CODE = 0
    ERROR_CODE = 1
    ERROR_FORMAT = '%<file>s:%<line>i: %<text>s (suggestions: %<suggestions>s)'
    EXTENSIONS_PROMPT = 'Forspell inspects *.rb, *.c, *.cpp, *.md files'
    SUMMARY = '%<files>i inspected, %<errors>s detected'

    def initialize(logfile:,
                   verbose:,
                   format:)

      FileUtils.touch(logfile) if logfile.is_a?(String)
      @logger = Logger.new(logfile || STDERR)
      @logger.level = verbose ? Logger::INFO : Logger::WARN
      @logger.formatter = proc { |*, msg| "#{msg}\n" }
      @format = format

      @pastel = Pastel.new(enabled: $stdout.tty?)
      @errors = []
      @files = []
    end

    def file(path)
      @logger.info "Processing #{path}"
      @files << path
    end

    def error(word, suggestions)
      @errors << [word, suggestions]
      puts readable(word, suggestions) if @format == 'readable'
    end

    def parsing_error(error)
      @logger.error "Parsing error in #{@files.last}: #{error}"
    end

    def report
      case @format
      when 'readable'
        print_summary
      when 'dictionary'
        print_dictionary
      when 'json', 'yaml'
        print_formatted
      end
    end

    def finalize
      @errors.empty? ? SUCCESS_CODE : ERROR_CODE
    end

    private

    def readable(word, suggestions)
      format(ERROR_FORMAT,
             file: word[:file],
             line: word[:line],
             text: @pastel.red(word[:text]),
             suggestions: suggestions.join(', '))
    end

    def print_formatted
      @errors.map { |word, suggestions| word.to_h.merge(suggestions: suggestions) }
             .public_send("to_#{@format}")
             .tap { |res| puts res }
    end

    def print_summary
      err_count = @errors.size
      color = err_count.positive? ? :red : :green
      total_errors_colorized = @pastel.decorate(err_count.to_s, color)

      puts EXTENSIONS_PROMPT
      puts format(SUMMARY, files: @files.size, errors: total_errors_colorized)
    end

    def print_dictionary
      @errors.map(&:first)
             .group_by(&:text)
             .transform_values { |v| v.map(&:file).uniq }
             .sort_by { |word, *| word.downcase }
             .each do |text, files|
        files.each { |file| puts "\# #{file}" }
        puts @pastel.decorate(text, :red)
      end
    end
  end
end

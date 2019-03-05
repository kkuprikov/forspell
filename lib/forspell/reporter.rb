# frozen_string_literal: true

require 'fileutils'
require 'pastel'
require 'logger'

module Forspell
  class Reporter
    SUCCESS_CODE = 0
    ERROR_CODE = 1
    FORMAT = '%<file>s:%<line>i: %<text>s (suggestions: %<suggestions>s)'

    def initialize(logfile:,
                   verbose:,
                   format:,
                   group:)

      FileUtils.touch(logfile) if logfile.is_a?(String)
      @logger = Logger.new(logfile || STDOUT)
      @logger.level = verbose ? Logger::INFO : Logger::WARN

      @logger.formatter = proc do |_severity, _datetime, _progname, msg|
        "#{msg}\n"
      end

      @format = group ? 'group' : format

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
      @error_logger.warn "PARSING ERROR IN #{@files.last}: #{error}"
    end

    def report
      case @format
      when 'readable'
        err_count = @errors.size

        color = err_count.positive? ? :red : :green
        total_errors_colorized = @pastel.decorate(err_count.to_s, color)

        puts 'Forspell inspects *.rb, *.c, *.cpp, *.md files'
        puts "#{@files.size} files inspected, #{total_errors_colorized} errors detected"
      when 'group'
        @errors.flat_map(&:first)
               .group_by { |word| word[:text] }
               .transform_values { |v| v.map { |word| word[:file] }.uniq }
               .sort_by { |key| key.first.downcase }
               .each do |errors| # [word, [files]]
          errors.last.each { |file| puts "\# #{file}" }
          puts @pastel.decorate(errors.first, :red)
        end
      when 'json', 'yaml'
        print_formatted
      end
    end

    def finalize
      @errors.size.positive? ? ERROR_CODE : SUCCESS_CODE
    end

    private

    def readable(word, suggestions)
      format(FORMAT, file: word[:file], line: word[:line], text: @pastel.red(word[:text]), suggestions: suggestions.join(', '))
    end

    def print_formatted
      puts (@errors.map do |error|
        {
          file: error.first[:file],
          line: error.first[:line],
          error: error.first[:text],
          suggestions: error.last
        }
      end.public_send("to_#{@format}"))
    end
  end
end

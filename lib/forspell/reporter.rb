# frozen_string_literal: true

require 'fileutils'
require 'pastel'
require 'logger'

module Forspell
  class Reporter
    SUCCESS_CODE = 0
    ERROR_CODE = 1

    attr_reader :total_errors

    def initialize(logfile:,
                   verbose:,
                   format:,
                   group:)

      FileUtils.touch(logfile) if logfile.is_a?(String)
      @logger = Logger.new(logfile || STDOUT)
      @error_logger = Logger.new(STDERR)

      [@logger, @error_logger].each do |logger|
        logger.formatter = proc do |_severity, _datetime, _progname, msg|
          "#{msg}\n"
        end
      end

      @verbose = verbose
      @format = group ? 'group' : format

      @pastel = Pastel.new(enabled: $stdout.tty?)
      @errors = []
    end

    def file(path)
      @logger.info "Processing #{path}" if @verbose
      @files_count ||= 0
      @files_count += 1
      @current_file = path
    end

    def error(word, suggestions)
      if @format != 'readable'
        @errors << format(word, suggestions)
      else
        @total_errors ||= 0
        @total_errors += 1
        @logger.info format(word, suggestions)
      end
    end

    def parsing_error(error)
      @error_logger.warn "PARSING ERROR IN #{@current_file}: #{error}"
    end

    def report
      @total_errors ||= @errors.size

      case @format
      when 'readable'
        @logger.info 'Forspell inspects *.rb, *.c, *.cpp, *.md files'
        color = @total_errors.positive? ? :red : :green
        total_errors_colorized = @pastel.decorate(total_errors.to_s, color)

        @logger.info "#{@files_count} files inspected, #{total_errors_colorized} errors detected"
      when 'group'
        tmp_hash = {}

        @errors.each do |error|
          tmp_hash[error[:error]] ||= []
          tmp_hash[error[:error]] << "\# #{error[:file]}"
        end

        tmp_hash.keys.sort.each do |error|
          tmp_hash[error].uniq.map { |loc| @logger.info loc }
          @logger.info @pastel.red(error)
        end
      when 'json'
        @logger.info @errors.to_json
      when 'yaml'
        @logger.info @errors.to_yaml
      end
    end

    def finalize
      total_errors.positive? ? ERROR_CODE : SUCCESS_CODE
    end

    private

    def format(word, suggestions)
      if @format == 'readable'
        "#{word[:file].gsub('//', '/')}:#{word[:line]}: #{@pastel.red(word[:text])} (suggestions: #{suggestions.join(', ')})"
      else
        {
          file: word[:file].gsub('//', '/'),
          line: word[:line],
          error: word[:text],
          suggestions: suggestions
        }
      end
    end
  end
end

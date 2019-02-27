# frozen_string_literal: true

require 'fileutils'
require 'pastel'
require 'logger'

class Reporter
  attr_reader :total_errors

  def initialize(logfile:,
                 verbose:,
                 format:,
                 group:)

    FileUtils.touch(logfile) if logfile.is_a?(String)
    @logger = Logger.new(logfile || STDOUT)
    @logger.formatter = proc do |_severity, _datetime, _progname, msg|
      "#{msg}\n"
    end

    @verbose = verbose
    @format = group ? 'group' : format

    @pastel = Pastel.new(enabled: $stdout.tty?)
    @errors = []
  end

  def file path
    @logger.info "Processing #{path}" if @verbose
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

  def report(parsing_errors, total_files)
    @total_errors ||= @errors.size

    case @format
    when 'readable'
      @logger.info 'Forspell inspects *.rb, *.c, *.cpp, *.md files'

      total_errors_colorized = @pastel.decorate(total_errors.to_s, @total_errors.positive? ? :red : :green)
      parsing_errors.each do |error|
        @logger.info "PARSING ERROR: #{error.inspect}"
      end

      @logger.info "#{total_files} files inspected, #{total_errors_colorized} errors detected"
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

  private

  def format(word, suggestions)
    if @format == 'readable'
      "#{word[:file]}:#{word[:line]}: #{@pastel.red(word[:text])} (suggestions: #{suggestions.join(', ')})"
    else
      {
        file: word[:file],
        line: word[:line],
        error: word[:text],
        suggestions: suggestions
      }
    end
  end
end

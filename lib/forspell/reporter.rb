# frozen_string_literal: true

require 'fileutils'
require 'pastel'
require 'logger'
require 'json'
require 'highline'
require 'ruby-progressbar'

module Forspell
  class Reporter
    SUCCESS_CODE = 0
    ERROR_CODE = 1
    DICT_PATH = File.join(Dir.pwd, 'forspell.dict')
    DICT_OVERWRITE = 'Do you want to overwrite forspell.dict? (yN)'
    DICT_PROMPT = <<~PROMPT 
      # Format: one word per line. Empty lines and #-comments are supported too.
      # If you want to add word with its forms, you can write 'word: example' (without quotes) on the line,
      # where 'example' is existing word with the same possible forms (endings) as your word.
      # Example: deduplicate: duplicate
    PROMPT
    SUGGEST_FORMAT = '(suggestions: %<suggestions>s)'
    ERROR_FORMAT = '%<file>s:%<line>i: %<text>s %<suggest>s'
    SUMMARY = "Forspell inspects *.rb, *.c, *.cpp, *.md files\n"\
              '%<files>i file%<files_plural>s inspected, %<errors>s error%<errors_plural>s detected'

    attr_accessor :progress_bar

    def initialize(logfile:,
                   verbose:,
                   format:,
                   print_filepaths: false)

      FileUtils.touch(logfile) if logfile.is_a?(String)
      @logger = Logger.new(logfile || STDERR)
      @logger.level = verbose ? Logger::INFO : Logger::WARN
      @logger.formatter = proc { |*, msg| "#{msg}\n" }
      @format = format

      @pastel = Pastel.new(enabled: $stdout.tty?)
      @errors = []
      @files = []
      @print_filepaths = print_filepaths
    end

    def file(path)
      @logger.info "Processing #{path}"
      @files << path
    end

    def error(word, suggestions)
      @errors << [word, suggestions]
      print(readable(word, suggestions)) if @format == 'readable'
    end

    def parsing_error(error)
      @logger.error "Parsing error in #{@files.last}: #{error}"
    end

    def path_load_error(path)
      @logger.error "Path not found: #{path}"
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
      suggest = format(SUGGEST_FORMAT, suggestions: suggestions.join(', ')) unless suggestions.empty?

      format(ERROR_FORMAT,
             file: word[:file],
             line: word[:line],
             text: @pastel.red(word[:text]),
             suggest: suggest)
    end

    def print_formatted
      @errors.map { |word, suggestions| word.to_h.merge(suggestions: suggestions) }
             .public_send("to_#{@format}")
             .tap { |res| print res }
    end

    def print_summary
      err_count = @errors.size
      color = err_count.positive? ? :red : :green
      total_errors_colorized = @pastel.decorate(err_count.to_s, color)

      print format(SUMMARY,
                   files: @files.size,
                   errors: total_errors_colorized,
                   files_plural: @files.size == 1 ? '' : 's',
                   errors_plural: err_count == 1 ? '' : 's')
    end

    def print_dictionary
      puts DICT_PATH
      if File.exist?(DICT_PATH)
        cli = HighLine.new
        answer = cli.ask(DICT_OVERWRITE)
        out = answer.downcase == 'y' ? File.new(DICT_PATH, 'w') : exit(1)
      else
        out = File.new(DICT_PATH, 'w')
      end
      out.puts DICT_PROMPT unless out.tty?
      @errors.map(&:first)
             .group_by(&:text)
             .transform_values { |v| v.map(&:file).uniq }
             .sort_by { |word, *| word.downcase }
             .each do |text, files|
        files.each { |file| out.puts "\# #{file}" } if @print_filepaths
        out.puts out.tty? ? @pastel.decorate(text, :red) : text
      end
    end

    private

    def print(something)
      $stdout.tty? ? @progress_bar&.log(something) : puts(something)
    end
  end
end

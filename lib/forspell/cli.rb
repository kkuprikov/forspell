# frozen_string_literal: true

require 'slop'
require 'backports/2.5.0/hash/slice'
require_relative 'runner'
require_relative 'speller'
require_relative 'reporter'
require_relative 'file_list'

module Forspell
  class CLI
    ERROR_CODE = 2
    CONFIG_PATH = File.join(Dir.pwd, '.forspell')
    DEFAULT_CUSTOM_DICT = File.join(Dir.pwd, 'forspell.dict')

    FORMATS = %w[readable yaml json].freeze
    FORMAT_ERR = "must be one of the following: #{FORMATS.join(', ')}"
    DEFINITIONS = proc do |o|
      o.array '-e', '--exclude-paths', 'List of paths to exclude'
      o.string '-d', '--dictionary-path', 'Path to main hunspell dictionary to use (by default, forspell\'s en_US)', default: 'en_US'
      o.array '-c', '--custom-paths', 'Paths to custom dictionaries', default: []
      o.string '-f', '--format', 'Output formats: readable(default), JSON, YAML', default: 'readable'
      o.bool '--gen-dictionary', 'Generate custom dictionary', default: false
      o.bool '--print-filepaths', 'Enable file paths in dictionary mode', default: false
      o.string '-l', '--logfile', 'Log to specified path'
      o.bool '-v', '--verbose', 'Verbose mode', default: false
      o.bool '--no-suggest', 'Output without suggestions', default: false
      o.integer '--suggestions-size', 'How many suggestions for each error should be returned', default: 3
      o.on '--help' do
        puts o
        exit
      end
    end

    def initialize options
      @options = options
    end

    def call
      init_options
      create_files_list
      init_speller
      init_reporter
      run
    end

    private

    def create_files_list
      @files = FileList.new(paths: @opts.arguments, exclude_paths: @opts[:exclude_paths])
    end

    def init_options
      @options += File.read(CONFIG_PATH).tr("\n", ' ').split(' ') if File.exist?(CONFIG_PATH)

      @opts = Slop.parse(@options, &DEFINITIONS)

      if @opts.arguments.empty?
        puts 'Usage: forspell paths to check [options]'
        puts 'Type --help for more info'
        exit(ERROR_CODE)
      end
      
      @opts[:format] = 'dictionary' if @opts[:gen_dictionary]
      @opts[:format] = @opts[:format]&.downcase
    end

    def init_speller
      @opts[:custom_paths].each do |path|
        next if File.exist?(path)

        puts "Custom dictionary not found: #{path}"
        exit(ERROR_CODE)
      end

      @opts[:custom_paths] << DEFAULT_CUSTOM_DICT if File.exist?(DEFAULT_CUSTOM_DICT)
      suggestions_size = (@opts[:gen_dictionary] || @opts[:no_suggest]) ? 0 : @opts[:suggestions_size]
      suggestions_size ||= 0

      @speller = Speller.new(@opts[:dictionary_path], *@opts[:custom_paths], suggestions_size: suggestions_size)
    end

    def init_reporter
      @reporter = Reporter.new(**@opts.to_hash.slice(:logfile, :format, :verbose, :print_filepaths))
    end

    def run
      runner = Forspell::Runner.new(files: @files, speller: @speller, reporter: @reporter)
      runner.call
      exit @reporter.finalize
    rescue Forspell::FileList::PathLoadError => path
      @reporter.path_load_error path
      exit ERROR_CODE
    end
  end
end

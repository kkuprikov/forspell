# frozen_string_literal: true

require 'optimist'
require 'backports/2.5.0/hash/slice'
require_relative 'runner'
require_relative 'speller'
require_relative 'reporter'
require_relative 'loaders/file_loader'

module Forspell
  class CLI
    ERROR_CODE = 2
    CONFIG_PATH = File.join(Dir.pwd.to_s, '.forspell')
    DEFAULT_CUSTOM_DICT = File.join(Dir.pwd.to_s, '.forspell.dict')

    FORMATS = %w[readable yaml json].freeze
    FORMAT_ERR = "must be one of the following: #{FORMATS.join(', ')}"

    OPTION_KEYS = %i[
      dictionary_name
      custom_dictionaries
      format
      logfile
      verbose
      group
    ].freeze

    def self.call
      init_options
      create_files_list
      init_speller
      init_reporter
      run
    end

    def self.create_files_list
      @files = ARGV.flat_map do |path|
        if File.directory?(path)
          Loaders::FileLoader.new(path: path,
                                  exclude_paths: @opts[:exclude_paths] || [])
                             .process.result
        else
          [path]
        end
      end
    end

    def self.init_options
      options = ARGV
      options += File.read(CONFIG_PATH).tr("\n", ' ').split(' ') if File.exist?(CONFIG_PATH)

      @opts = Optimist.options(options) do
        opt :exclude_paths, 'Specify subdirectories to exclude', type: :strings
        opt :dictionary_name, 'Use another hunspell dictionary', default: 'en_US', type: :string
        opt :custom_dictionaries, 'Add your custom dictionaries by specifying paths', type: :strings, default: []
        opt :format, 'Formats: readable, YAML, JSON', default: 'readable', type: :string
        opt :logfile, 'Log to file', type: :string
        opt :verbose, 'Show progress'
        opt :group, 'Group errors in dictionary format'
      end

      @opts[:format] = @opts[:format].downcase
      Optimist.die :format, FORMAT_ERR unless FORMATS.include?(@opts[:format])
      puts 'Type --help for available options' if @opts[:format] == 'readable' && !@opts[:group]
    end

    def self.init_speller
      @opts[:custom_dictionaries].each do |path|
        next if File.exist?(path)

        puts "Custom dictionary not found: #{path}"
        @opts[:custom_dictionaries].delete(path)
      end

      @opts[:custom_dictionaries] << DEFAULT_CUSTOM_DICT if File.exist?(DEFAULT_CUSTOM_DICT)

      @speller = Speller.new(@opts[:dictionary_name], *@opts[:custom_dictionaries])
    end

    def self.init_reporter
      @reporter = Reporter.new(
        logfile: @opts[:logfile],
        format: @opts[:format],
        verbose: @opts[:verbose],
        group: @opts[:group]
      )
    end

    def self.run
      runner = Forspell::Runner.new(files: @files, speller: @speller, reporter: @reporter)
      runner.call
      exit @reporter.finalize
    end
  end
end

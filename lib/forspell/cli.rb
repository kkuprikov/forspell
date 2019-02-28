# frozen_string_literal: true

require 'optimist'
require 'backports/2.5.0/hash/slice'
require_relative 'runner'
require_relative 'loaders/file_loader'

module Forspell
  class CLI
    CONFIG_PATH = "#{Dir.pwd}/.forspell"
    DEFAULT_CUSTOM_DICT = "#{Dir.pwd}/.forspell.dict"
    RUBY_DICT = "#{__dir__}/ruby.dict"

    FORMATS = %w[readable yaml YAML json JSON].freeze
    FORMAT_ERR = 'must be one of the following: readable, yaml, json'

    OPTION_KEYS = %i[
      dictionary_name
      custom_dictionaries
      format
      logfile
      verbose
      group
    ].freeze

    def self.call
      @opts = Optimist.options do
        opt :include_paths, 'Include additional directories, default: lib, app', type: :strings
        opt :exclude_paths, 'Specify subdirectories to exclude', type: :strings
        opt :dictionary_name, 'Use another hunspell dictionary', default: 'en_US', type: :string
        opt :custom_dictionaries, 'Add your custom dictionaries by specifying paths', type: :strings, default: []
        opt :format, 'Formats: readable, YAML, JSON', default: 'readable', type: :string
        opt :logfile, 'Log to file', type: :string
        opt :verbose, 'Show progress'
        opt :group, 'Group errors in dictionary format'
      end
      Optimist.die :format, FORMAT_ERR unless FORMATS.include?(@opts[:format])

      if ARGV.empty?
        puts 'Please, specify at least one working directory or file'
        exit(2)
      end

      if File.exist?(CONFIG_PATH)
        file_opts = File.read(CONFIG_PATH).split("\n").map do |option|
          option.gsub('--', '').split(' ')
        end.to_h

        file_opts.keys.each do |key|
          file_opts[(begin
                       key.to_sym
                     rescue StandardError
                       key
                     end) || key] = file_opts.delete(key)
        end

        @opts.merge!(file_opts)
      end

      @opts[:custom_dictionaries] << DEFAULT_CUSTOM_DICT
      @opts[:custom_dictionaries] << RUBY_DICT

      @opts[:custom_dictionaries].each do |path|
        unless File.exist?(path)
          puts "Custom dictionary not found: #{path}"
          @opts[:custom_dictionaries].delete(path)
        end
      end

      puts 'Type --help for available options' if @opts[:format] == 'readable' && !@opts[:group]

      Forspell::Runner.new(@opts.slice(*OPTION_KEYS).merge(files: files, format: @opts[:format].downcase)).process
                      .total_errors.positive? ? exit(1) : exit(0)
    end

    private

    def self.files
      ARGV.map do |path|
        if File.extname(path).empty?
          Loaders::FileLoader.new(path: path,
                                  include_paths: @opts[:include_paths] || [],
                                  exclude_paths: @opts[:exclude_paths] || [])
                             .process.result
        else
          [path]
        end
      end.reduce(:+)
    end
  end
end

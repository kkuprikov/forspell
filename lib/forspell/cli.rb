require 'optimist'
require 'backports/2.5.0/hash/slice'
require_relative '../lib/forspell'

module Forspell
  class CLI

    CONFIG_PATH = "#{Dir.pwd}/.forspell"
    DEFAULT_CUSTOM_DICT = "#{Dir.pwd}/.forspell.dict"

    FORMATS = %w(readable yaml YAML json JSON)
    FORMAT_ERR = 'must be one of the following: readable, yaml, json'

    OPTION_KEYS = %i[
      include_paths
      exclude_paths
      dictionary_name
      custom_dictionary_paths
      format
      logfile
      verbose
      group
    ].freeze


    opts = Optimist.options do
      opt :include_paths, 'Include additional directories, default: lib, app', type: :strings
      opt :exclude_paths, 'Specify subdirectories to exclude', type: :strings
      opt :dictionary_name, 'Use another hunspell dictionary', default: 'en_US', type: :string
      opt :custom_dictionary_paths, 'Add your custom dictionaries by specifying paths', type: :strings, default: []
      opt :format, 'Formats: readable, YAML, JSON', default: 'readable', type: :string
      opt :logfile, 'Log to file', type: :string
      opt :verbose, 'Show progress'
      opt :group, 'Group errors in dictionary format'
    end
    Optimist.die :format, FORMAT_ERR unless FORMATS.include?(opts[:format])

    if ARGV.empty?
      puts 'Please, specify working directory or file'
      exit(2)
    end


    if File.exist?(CONFIG_PATH)
      file_opts = File.read(CONFIG_PATH).split("\n").map do |option|
        option.gsub('--', '').split(' ')
      end.to_h

      file_opts.keys.each do |key|
        file_opts[(key.to_sym rescue key) || key] = file_opts.delete(key)
      end

      opts.merge!(file_opts)
    end

    opts[:custom_dictionary_paths] << DEFAULT_CUSTOM_DICT if File.exist?(DEFAULT_CUSTOM_DICT)

    puts 'Type --help for available options' if opts[:format] == 'readable' && !opts[:group]
  end
end
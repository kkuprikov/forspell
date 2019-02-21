require 'logger' 
require 'json'
require 'ffi/hunspell'
require 'fileutils'
require 'colorize'
require 'pry'
require_relative 'loaders/yardoc_loader'
require_relative 'loaders/markdown_loader'
require_relative 'loaders/ruby_doc_loader'
require_relative 'loaders/c_doc_loader'
require_relative 'loaders/file_loader'

class Forspell
  HUNSPELL_DIRS = [ "#{__dir__}/dictionaries" ]

  EXT_TO_PARSER_CLASS = {
    '.rb' => RubyDocLoader,
    '.c' => CDocLoader,
    '.cpp' => CDocLoader,
    '.cxx' => CDocLoader,
    '.md' => MarkdownLoader
  }

  attr_reader :dictionaries, :result, :total_errors

  def initialize(
    dictionary_name: 'en_US', 
    logfile: nil, 
    paths: nil, 
    exclude_paths: [],
    include_paths: [],
    custom_dictionary_paths: nil,
    no_output: false,
    verbose: false,
    format: 'readable',
    group: false,
    ruby_dictionary_path: "#{ __FILE__.split('/')[0..-2].join('/') }/ruby.dict")

    begin
      FFI::Hunspell.directories = HUNSPELL_DIRS
      @dictionaries = [FFI::Hunspell.dict(dictionary_name)]
      dictionary_inputs = File.read(ruby_dictionary_path)&.split("\n")
      if custom_dictionary_paths
        dictionary_inputs += custom_dictionary_paths.map do |path|
          File.read(path)&.split("\n")
        end.flatten
      end

      dictionary_inputs.compact
        .map{ |line| line.gsub(/\s*\#.*$/, '') }
        .reject(&:empty?)
        .map{ |line| line.split(/\s*:\s*/, 2) }
        .each do |word, example| 
          example ? @dictionaries.first.add_with_affix(word, example) : @dictionaries.first.add(word)
        end
    rescue ArgumentError
      puts "Unable to find the dictionary #{ dictionary_name } in any of the directories"
      exit(2)
    end

    @paths = paths.is_a?(Array) ? paths : [paths]
    @format = format
    @verbose = verbose
    @group = group
    @include_paths = include_paths || []
    @exclude_paths = exclude_paths || []

    unless no_output
      FileUtils.touch(logfile) if logfile.is_a?(String)
      @logger = Logger.new(logfile || STDOUT)
      @logger.formatter = proc do |severity, datetime, progname, msg|
        "#{ msg }\n"
      end
    end
  end

  def check_spelling words
    words.reject{ |word| dictionaries.any?{ |dict| dict.check?(word) } }.sort.uniq
  end

  def process
    @result = load_words_from_files.flatten.reject{ |part| part[:errors].empty? }
    
    pretty_print(result, 'group') if @logger && @group
    
    @total_errors = result.map{ |obj| obj[:errors].size }.reduce(:+) || 0
    print_summary(total_files: @files.size, total_errors: @total_errors) if @logger && @format == 'readable' && !@group

    self
  end

  private

  def load_words_from_files
    @files = @paths.map do |path|
      File.extname(path).empty? ? FileLoader.new(path: path, include_paths: @include_paths, exclude_paths: @exclude_paths).process.result
      : [path]
    end.reduce(:+)

    @files.map do |file|
      file = file.gsub('//', '/')
      @logger.info "Processing #{file}" if @logger && @verbose
      parsed_file = EXT_TO_PARSER_CLASS[File.extname(file)].new(file: file).process.result
      parsed_file.map do |part|
        part[:errors] = check_spelling(part[:words])
        part[:errors_with_suggestions] = part[:errors].map{ |word| [word, dictionaries.map{ |dict| dict.suggest(word) }.flatten.first(3)] }.to_h
        part.delete(:words)
        pretty_print([part], @format) if @logger && !@group
        part
      end
    end
  end

  def pretty_print result, format
    case format
    when 'json'
      result.each do |object|
        object[:errors_with_suggestions].each_pair do |err, suggestions|
          @logger.info ({ file: object[:file],
            line: object[:location],
            error: err,
            suggestions: suggestions
          }.to_json)
        end
      end
    when 'yaml'
      result.each do |object|
        object[:errors_with_suggestions].each_pair do |err, suggestions|
          @logger.info ({ 'file' => object[:file],
            'line' => object[:location],
            'error' => err,
            'suggestions' => suggestions
          }.to_yaml)
        end
      end
    when 'readable'
      result.each do |object|
        @logger.info "#{'PARSING ERROR'.red} #{object[:file]}:#{ object[:location] }\n#{object[:error_desc]}" if object[:parsing_error]
        object[:errors_with_suggestions].each_pair do |error, suggestion|
          @logger.info "#{object[:file]}:#{ object[:location] }: '#{ error.to_s.red }' (suggestions: #{ suggestion.map{|s| '\'' + s + '\''}.join(', ') })"
        end
      end

    when 'group'
      tmp_hash = {}
      result.each do |object|
        object[:errors].each do |error|
          tmp_hash[error] ||= []
          tmp_hash[error] << "\# #{object[:file]}"
        end
      end

      tmp_hash.each_pair do |error, locations|
        locations.map { |loc| @logger.info loc }
        @logger.info error.red
      end
    end
  end

  def print_summary total_files: 0, total_errors: 0
    @logger.info 'Forspell inspects *.rb, *.c, *.cpp, *.md files'
    total_errors_colorized = total_errors.to_s.public_send(total_errors.positive? ? :red : :green)
    @logger.info "#{total_files} files inspected, #{total_errors_colorized} errors detected"
  end
end
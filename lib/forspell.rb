require 'logger' 
require 'json'
require 'ffi/hunspell'
require 'fileutils'
require_relative 'loaders/yardoc_loader'
require_relative 'loaders/markdown_loader'
require_relative 'loaders/ruby_doc_loader'
require_relative 'loaders/c_doc_loader'
require_relative 'loaders/file_loader'

class Forspell
  EXT_TO_PARSER_CLASS = {
    '.rb' => RubyDocLoader,
    '.c' => CDocLoader,
    '.cpp' => CDocLoader,
    '.cxx' => CDocLoader,
    '.md' => MarkdownLoader
  }

  attr_reader :dictionaries, :result

  def initialize(
    dictionary_name: 'en_US', 
    logfile: nil, 
    path: nil, 
    exclude_paths: [],
    include_paths: [],
    custom_dictionary_path: nil,
    no_output: false, 
    format: 'readable', 
    ruby_dictionary_path: "#{ __FILE__.split('/')[0..-2].join('/') }/ruby.dict")

    fail 'Please specify working directory or file' unless path

    begin
      @dictionaries = [FFI::Hunspell.dict(dictionary_name)]
      dictionary_inputs = File.read(ruby_dictionary_path)&.split("\n")
      dictionary_inputs += File.read(custom_dictionary_path)&.split("\n") if custom_dictionary_path

      dictionary_inputs.compact
        .map{ |line| line.gsub(/\s*\#.*$/, '') }
        .reject(&:empty?)
        .map{ |line| line.split(/\s*:\s*/, 2) }
        .each do |word, example| 
          example ? @dictionaries.first.add_with_affix(word, example) : @dictionaries.first.add(word)
        end
    rescue ArgumentError
      fail "Unable to find the dictionary #{ dictionary_name } in any of the directories"
    end

    @path = path
    @format = format
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
    @result = load_words_from_files.flatten.map do |part|
      part[:errors] = check_spelling(part[:words])
      part[:errors_with_suggestions] = part[:errors].map{ |word| [word, dictionaries.map{ |dict| dict.suggest(word) }.flatten.first(3)] }.to_h
      part.delete(:words)
      part 
    end.reject{ |part| part[:errors].empty? }

    pretty_print(result, @format) if @logger
    self
  end

  private

  def load_words_from_files
    files = File.extname(@path).empty? ? FileLoader.new(path: @path, include_paths: @include_paths, exclude_paths: @exclude_paths).process.result
      : [@path]
    files.map do |file|
      @logger.info "Processing #{file.gsub('//', '/')}" if @logger
      EXT_TO_PARSER_CLASS[File.extname(file)].new(file: file).process.result
    end
  end

  def pretty_print result, format
    total_errors = result.map{ |obj| obj[:errors].size }.reduce(:+)

    case format
    when 'json'
      result.each { |object| @logger.info object.to_json }
    when 'yaml', 'yml'
      @logger.info result.to_yaml
    when 'readable'
      result.each do |object| 
        object[:errors_with_suggestions].each_pair do |error, suggestion|
          @logger.info "#{object[:file]}:#{ object[:location] }: '#{ error }' (suggestions: #{ suggestion.map{|s| '\'' + s + '\''}.join(', ') })"
        end
      end

      print_summary(total_files: result.size, total_errors: total_errors)

    when 'dictionary'
      tmp_hash = {}
      result.each do |object|
        object[:errors].each do |error|
          tmp_hash[error] ||= []
          tmp_hash[error] += "\##{object[:file]}:#{ object[:location] }"
        end
      end

      tmp_hash.each_pair do |error, locations|
        locations.map { |loc| @logger.info loc }
        @logger.info error
      end
      print_summary(total_files: result.size, total_errors: total_errors)
    end
  end

  def print_summary total_files: 0, total_errors: 0
    @logger.info 'Forspell inspects *.rb, *.c, *.cpp, *.md files'
    @logger.info "#{total_files} inspected, #{total_errors} detected"
  end
end
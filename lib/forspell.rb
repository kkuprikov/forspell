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
    custom_dictionary: nil,
    no_output: false, 
    format: 'readable', 
    ruby_dictionary_path: "#{ __FILE__.split('/')[0..-2].join('/') }/ruby.dict")

    fail 'Please specify working directory or file' unless path
    return if exclude_paths.include?(path)

    begin
      @dictionaries = [FFI::Hunspell.dict(dictionary_name)]
      @dictionaries << FFI::Hunspell.dict(custom_dictionary) if custom_dictionary

      File.read(ruby_dictionary_path).split("\n")
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
    @include_paths = include_paths
    @exclude_paths = exclude_paths

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
      EXT_TO_PARSER_CLASS[File.extname(file)].new(file: file).process.result
    end
  end

  def pretty_print result, format
    case format
    when 'json'
      result.each { |object| @logger.info object.to_json }
    when 'yaml', 'yml'
      @logger.info result.to_yaml
    when 'readable'
      result.each do |object| 
        object[:errors_with_suggestions].each_pair do |error, suggestion|
          @logger.info "#{object[:file]}:#{ object[:location] }: '#{ error }' is incorrect, possible suggestions are: #{ suggestion.map{|s| '\'' + s + '\''}.join(', ') }"
        end
      end
    end
  end 
end
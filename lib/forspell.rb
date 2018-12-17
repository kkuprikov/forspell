require 'logger' 
require 'json'
require 'ffi/hunspell'
require 'fileutils'
require_relative 'loaders/yardoc_loader'
require_relative 'loaders/markdown_loader'

class Forspell
  FORMATS_TO_LOADERS_MAP = {
    '.rb' => YardocLoader,
    '.md' => MarkdownLoader
  }

  attr_reader :dictionaries, :result

  def initialize(
    dictionary_name: 'en_US', 
    logfile: nil, 
    path: nil, 
    exclude_path: nil,
    custom_dictionary: nil,
    no_output: false, 
    format: 'readable', 
    ruby_dictionary_path: 'lib/ruby.dict')

    fail 'Please specify working directory or file' unless path

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
    rescue Errno::ENOENT
    rescue ArgumentError
      fail "Unable to find the dictionary #{ dictionary_name } in any of the directories"
    end

    @file = path
    @loader_class = loader_class(@file)
    @format = format
    @exclude_path = exclude_path

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
    data = @loader_class.new(file: @file, exclude_path: @exclude_path).process.result

    @result = data.map do |part| 
      part[:errors] = check_spelling(part[:words])
      part[:errors_with_suggestions] = part[:errors].map{ |word| [word, dictionaries.map{ |dict| dict.suggest(word) }.flatten.first(3)] }.to_h
      part.delete(:words)
      part 
    end.reject{ |part| part[:errors].empty? }

    pretty_print(result, @format) if @logger
    self
  end

  private

  def loader_class file
    return YardocLoader unless file
    FORMATS_TO_LOADERS_MAP[File.extname(file)] || YardocLoader
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
          @logger.info "#{object[:file]}:#{ object[:location] }: '#{ error }' is incorrect, possible suggestion is '#{ suggestion }'"
        end
      end
    end
  end 
end
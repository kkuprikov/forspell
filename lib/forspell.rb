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

  attr_reader :dictionary, :result

  def initialize(dictionary_name: 'en_US', logfile: STDOUT, file: nil, no_output: false, format: 'readable', custom_dictionary_path: 'lib/ruby.dict')
    begin
      @dictionary = FFI::Hunspell.dict(dictionary_name)
      IO.read(custom_dictionary_path).split("\n").each{ |word| @dictionary.add(word) }
    rescue Errno::ENOENT
    rescue ArgumentError
      fail "Unable to find the dictionary #{ dictionary_name } in any of the directories"
    end

    @file = file
    @loader_class = loader_class(@file)
    @format = format

    unless no_output
      FileUtils.touch(logfile) if logfile.is_a?(String)
      @logger = Logger.new(logfile || STDOUT)
      @logger.formatter = proc do |severity, datetime, progname, msg|
        "#{ msg }\n"
      end
    end
  end

  def check_spelling words
    words.reject{ |word| dictionary.check?(word) }.sort.uniq
  end

  def process
    data = @loader_class.new(file: @file).process.result

    @result = data.map do |part| 
      part[:errors] = check_spelling(part[:words])
      part[:errors_with_suggestions] = part[:errors].map{ |word| [word, dictionary.suggest(word).first] }.to_h
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
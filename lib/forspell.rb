require 'logger' 
require 'ffi/hunspell'
require_relative 'loaders/yardoc_loader'
require_relative 'loaders/markdown_loader'

class Forspell
  FORMATS_TO_LOADERS_MAP = {
    '.rb' => YardocLoader,
    '.md' => MarkdownLoader
  }

  attr_reader :dictionary, :result

  def initialize(dictionary_name: 'en_US', logfile: STDOUT, file: nil, no_output: false)
    @dictionary = FFI::Hunspell.dict(dictionary_name)
    @file = file
    @loader_class = loader_class(@file)

    unless no_output
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

    pretty_print(result) if @logger
    self
  end

  private

  def loader_class file
    return YardocLoader unless file
    FORMATS_TO_LOADERS_MAP[File.extname(file)] || YardocLoader
  end

  def pretty_print result_hash
    # result_hash.each { |object| @logger.info object.to_s }
    @logger.info result_hash.to_yaml
  end 
end
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

  def initialize(dictionary_name: 'en_US', **params)
    @dictionary = FFI::Hunspell.dict(dictionary_name)
    @file = params[:file]
    @loader_class = loader_class(@file)

    unless params[:no_output]
      @logger = Logger.new(params[:logfile] || STDOUT)
      @logger.formatter = proc do |severity, datetime, progname, msg|
        "#{msg}\n"
      end
    end
  end

  def check_spelling words
    words.reject{ |word| dictionary.check?(word) }.sort.uniq
  end

  def process
    inputs_with_location = @loader_class.new(file: @file).process.result
    @result =  inputs_with_location.transform_values { |v| check_spelling(v) }.delete_if{ |k, v| v.empty? }

    pretty_print(result) if @logger
    self
  end

  private

  def loader_class file
    return YardocLoader unless file
    FORMATS_TO_LOADERS_MAP[File.extname(file)]
  end

  def pretty_print result_hash
    @logger.info 'Spellchecking result:'
    result_hash.each_pair { |object, errors| @logger.info "#{ object }: #{ errors.join(', ') }" }
  end
end
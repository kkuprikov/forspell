require 'logger' 
require 'rdoc'
require 'ffi/hunspell'

class Forspell
  RDOC_FORMATS = {
    'rd' => RDoc::RD,
    'markdown' => RDoc::Markdown
  }
  
  CODE_MARKERS = %w(_ # :)

  CUSTOM_DICTIONARY = %w(
    env
    http
    params
  )

  attr_reader :dictionary, :errors

  def initialize(dictionary_name: 'en_US', **params)
    @format_class = params[:markup] ? RDOC_FORMATS[params[:markup]] : RDoc::RD
    fail "Unsupported markup format: #{ params[:markup] }" unless @format_class

    @dictionary = FFI::Hunspell.dict(dictionary_name)
    @logger = Logger.new(params[:logfile] || STDOUT)
  end

  def check_spelling input
    words = input.split(/[^[[:word:]]_#:]+/)
    words.reject{ |word| dictionary.check?(word) }.sort.uniq
  end

  def check_docs docs
    hash_with_errors = docs.transform_values do |v| 
      { 
        docstring: v, 
        errors: filter_code_objects(check_spelling(extract_text(v))) 
      } 
    end.reject{ |k, v| v[:errors].empty? }

    pretty_print(hash_with_errors) unless hash_with_errors.empty?
  end

  private

  def extract_text docstring
    @format_class.parse(docstring).parts
      .select{ |part| part.is_a?(RDoc::Markup::Paragraph) }
      .map(&:parts).join(' ')
  end

  def pretty_print result_hash
    @errors = result_hash.map do |object_path, data|
      [ 
        "#{ object_path }:#{ data[:docstring].line_range }",
        data[:errors]
      ]
    end.to_h

    @logger.info 'Spellchecking result:'
    @errors.each_pair { |object, errors| @logger.info "#{ object }, #{ errors.join(', ') }" }
  end

  def range_or_line_number range
    range.size > 1  ? range : range.first
  end

  def filter_code_objects words
    words.reject do |word|
      CODE_MARKERS.any? { |marker| word.chars.include?(marker) } ||
      word.count(('A'..'Z').to_a.join) > 1 ||
      CUSTOM_DICTIONARY.include?(word.downcase)
    end
  end
end
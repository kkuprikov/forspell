require 'uri'
require 'ffi/hunspell'
require 'redcarpet'
require 'nokogiri'

class Forspell
  attr_reader :errors, :dictionary, :params

  def initialize(dictionary_name: 'en_US', params: {})
    @dictionary = FFI::Hunspell.dict(dictionary_name)
    @params = params
  end

  def check_spelling input
    words = input.split(/[^[[:word:]]_#]+/)
    @errors = words.select{ |word| simple_word?(word) && !dictionary.check?(word) }.sort.uniq
  end

  def check_file path
    file = File.open path, 'r'
    fail "Can\'t open the input file: #{ path }" unless file
    raw_input = ''

    file.each_line { |line| raw_input << line }
    markdown_parser = Redcarpet::Markdown.new(Redcarpet::Render::HTML,
      no_intra_emphasis: true,
      fenced_code_blocks: true)
    html_input = markdown_parser.render(raw_input)

    check_spelling sanitize_html(html_input)
  end

  private

  def simple_word? word
    return false if seems_like_class_name?(word) || seems_like_method_name?(word)
    return false if !params[:with_abbreviations] && seems_like_abbreviation?(word)
    /\w+/.match(word).to_s.size == word.size
  end

  def seems_like_class_name? word
    # prevents ClassName spellcheck
    uppercased_count = uppercased_chars_count(word)
    #still checking UPPERCASE though
    uppercased_count > 1 && uppercased_count < word.size
  end

  def seems_like_abbreviation? word
    uppercased_chars_count(word) == word.size
  end

  def seems_like_method_name? word
    underscores_count(word) > 0
  end

  def uppercased_chars_count word
    word.chars.select{ |char| uppercased?(char) }.size
  end

  def underscores_count word
    word.chars.select{ |char| char == '_' }.size
  end

  def uppercased? character
    /[[:upper:]]/.match(character)
  end

  def sanitize_html input
    parsed_html = Nokogiri::HTML input
    parsed_html.xpath('//code').remove
    parsed_html.xpath('//a').map { |link| link.remove_attribute('href') }
    parsed_html.text.gsub(/https?:\/\/[\S]+/, '')
  end
end
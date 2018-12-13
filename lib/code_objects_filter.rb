require 'sanitize'

module CodeObjectsFilter
  CODE_MARKERS = %w(_ # :).freeze
  URI_REGEX = %r"((?:(?:[^ :/?#]+):)(?://(?:[^ /?#]*))(?:[^ ?#]*)(?:\?(?:[^ #]*))?(?:#(?:[^ ]*))?)".freeze

  def filter_code_objects input
    split(sanitize_html(input)).reject do |word|
      CODE_MARKERS.any? { |marker| word.chars.include?(marker) } ||
      word.count(('A'..'Z').to_a.join) > 1 ||
      @custom_dictionary.include?(word)
    end
  end

  def split input
    result = input.split(/[^[[:word:]]_#:\'\.]+/)
    apostrophed_words = result.select{ |word| word[0] == "'" || word[-1] == "'" }
    dotted_words = result.select{ |word| word.chars.include?('.') }

    result -= apostrophed_words
    result -= dotted_words
    
    apostrophed_words.each do |word|
      fixed_word = word[1..-1] if  word.start_with?("'")
      fixed_word = word[1..-2] if  word.start_with?("'") && word.end_with?("'")
      fixed_word = word.chop   if !word.start_with?("'") && word.end_with?("'")
      result << (fixed_word || word)
    end

    dotted_words.each do |word|
      result << word.chop if word.end_with?(".") && word.chars.count('.') == 1 # exclude 'example.yml.' in the end of sentence
    end

    result
  end

  def sanitize_html input
    CGI.unescapeHTML Sanitize.fragment(input.gsub(URI_REGEX, ''), elements: [], remove_contents: true)
  end
end
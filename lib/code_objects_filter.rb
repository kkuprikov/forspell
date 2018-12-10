require 'sanitize'

module CodeObjectsFilter
  CODE_MARKERS = %w(_ # :).freeze

  def filter_code_objects input
    split(sanitize_html(input)).reject do |word|
      CODE_MARKERS.any? { |marker| word.chars.include?(marker) } ||
      word.count(('A'..'Z').to_a.join) > 1 ||
      @custom_dictionary.include?(word)
    end
  end

  def split input
    result = input.split(/[^[[:word:]]_#:\']+/)
    apostrophed_words = result.select{ |word| word[0] == "'" || word[-1] == "'" }
    result -= apostrophed_words
    
    apostrophed_words.each do |word|
      fixed_word = word[1..-1] if word.start_with?("'")
      fixed_word = word.chop if !word.end_with?("s'") && word.end_with?("'")
      result << (fixed_word || word)
    end
    result
  end

  def sanitize_html input
    CGI.unescapeHTML Sanitize.fragment(input, elements: [], remove_contents: true)
  end
end
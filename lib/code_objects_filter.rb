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
    input.split(/[^[[:word:]]_#:\']+/)
  end

  def sanitize_html input
    Sanitize.fragment(input, elements: [], remove_contents: true)
  end
end
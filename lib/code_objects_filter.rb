module CodeObjectsFilter
  CODE_MARKERS = %w(_ # :).freeze

  def filter_code_objects input
    words = input.split(/[^[[:word:]]_#:]+/)
    
    words.reject do |word|
      CODE_MARKERS.any? { |marker| word.chars.include?(marker) } ||
      word.count(('A'..'Z').to_a.join) > 1 ||
      @custom_dictionary.include?(word)
    end
  end
end
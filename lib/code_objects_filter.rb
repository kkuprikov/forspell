module CodeObjectsFilter
  CODE_MARKERS = %w(_ # :).freeze

  CUSTOM_DICTIONARY = %w(
    env
    http
    params
  )

  def filter_code_objects input
    words = input.split(/[^[[:word:]]_#:]+/)
    
    words.reject do |word|
      CODE_MARKERS.any? { |marker| word.chars.include?(marker) } ||
      word.count(('A'..'Z').to_a.join) > 1 ||
      CUSTOM_DICTIONARY.include?(word.downcase)
    end
  end
end
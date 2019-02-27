# frozen_string_literal: true

require 'sanitize'

module CodeObjectsFilter
  CODE_MARKERS = %w[_ # @].freeze
  URI_REGEX = %r{((?:(?:[^ :/?#]+):)(?://(?:[^ /?#]*))(?:[^ ?#]*)(?:\?(?:[^ #]*))?(?:#(?:[^ ]*))?)}.freeze

  def filter_code_objects(input)
    split(sanitize_html(input)).reject do |word|
      CODE_MARKERS.any? { |marker| word.include?(marker) } ||
        word.count(('A'..'Z').to_a.join) > 1 ||
        @custom_dictionary.include?(word) ||
        word.empty? || word.nil?
    end
  end

  def split(input)
    result = input.split(/[^[[:word:]]_@!#:\'\.]+/)
    apostrophed_words = result.select { |word| word[0] == "'" || word[-1] == "'" }
    dotted_words = result.select { |word| word.chars.include?('.') }
    semicolon_words = result.select { |word| word.chars.include?(':') }
    bang_words = result.select { |word| word.chars.include?('!') }

    result -= apostrophed_words
    result -= dotted_words
    result -= semicolon_words
    result -= bang_words

    apostrophed_words.each do |word|
      fixed_word = word[1..-1] if  word.start_with?("'")
      fixed_word = word[1..-2] if  word.start_with?("'") && word.end_with?("'")
      fixed_word = word.chop   if !word.start_with?("'") && word.end_with?("'")
      if fixed_word
        result += split(fixed_word)
      else
        result << word
      end
    end

    dotted_words.each do |word|
      result << word.chop if word.end_with?('.') && word.chars.count('.') == 1 # exclude 'example.yml.' in the end of sentence
    end

    semicolon_words.each do |word|
      result << word.chop if word.end_with?(':') && word.chars.count(':') == 1
    end

    bang_words.each do |word|
      result << word.chop if word.end_with?('!') && word.chars.count('!') == 1
    end

    result
  end

  def sanitize_html(input)
    CGI.unescapeHTML Sanitize.fragment(input.gsub(URI_REGEX, ''), elements: [], remove_contents: true)
  end
end

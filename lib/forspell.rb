require 'ffi/hunspell'

class Forspell
  attr_reader :errors, :dictionary

  def initialize(dictionary_name: 'en_US')
    @dictionary = FFI::Hunspell.dict(dictionary_name)
  end

  def check_spelling input
    words = input.split(/[^[[:word:]]_#]+/)
    @errors = words.select{ |word| simple_word?(word) && !dictionary.check?(word) }
  end

  private

  def simple_word? word
    return false if seems_like_classname?(word)
    /\w+/.match(word).to_s.size == word.size
  end

  def seems_like_classname? word
    # prevents ClassName spellcheck
    uppercased_chars_count(word) > 1
  end

  def uppercased_chars_count word
    word.chars.select{ |char| uppercased?(char) }.size
  end

  def uppercased? character
    /[[:upper:]]/.match(character)
  end
end
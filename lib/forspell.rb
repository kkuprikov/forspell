require 'ffi/hunspell'

class Forspell
  attr_reader :errors, :dictionary

  def initialize(dictionary_name: 'en_US')
    @dictionary = FFI::Hunspell.dict(dictionary_name)
  end

  def check_spelling input
    @errors = []
    words = input.split(/[^[[:word:]]']+/)
    words.map do |word|
      @errors << word unless dictionary.check?(word)
    end
    
    errors.empty? ? true : errors
  end
end
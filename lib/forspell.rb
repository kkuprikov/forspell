require 'ffi/hunspell'

class Forspell
  attr_reader :errors, :dictionary

  def initialize(dictionary_name: 'en_US')
    @dictionary = FFI::Hunspell.dict(dictionary_name)
  end

  def check_spelling input
    words = input.split(/[^[[:word:]]']+/)
    @errors = words.select { |word| !dictionary.check?(word) }
  end
end
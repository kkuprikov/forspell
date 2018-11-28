require 'ffi/hunspell'

class Forspell
  attr_reader :errors, :dictionary, :params

  def initialize(dictionary_name: 'en_US', **params)
    @dictionary = FFI::Hunspell.dict(dictionary_name)
    @params = params
  end

  def check_spelling input
    words = input.split(/[^[[:word:]]_#]+/)
    @errors = words.select{ |word| !dictionary.check?(word) }.sort.uniq
  end
end
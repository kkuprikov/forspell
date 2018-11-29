require 'ffi/hunspell'

class Forspell
  attr_reader :dictionary

  def initialize(dictionary_name: 'en_US')
    @dictionary = FFI::Hunspell.dict(dictionary_name)
  end

  def check_spelling input
    words = input.split(/[^[[:word:]]_#]+/)
    words.select{ |word| !dictionary.check?(word) }.sort.uniq
  end

  def check_docs hash
    hash.transform_values{ |v| check_spelling(v) }.select{ |k, v| !v.empty? }
  end
end
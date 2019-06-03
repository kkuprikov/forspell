# frozen_string_literal: true

require 'ffi/hunspell'
require 'backports/2.5.0/enumerable/all'

module Forspell
  class Speller
    attr_reader :dictionary

    HUNSPELL_DIRS = [File.join(__dir__, 'dictionaries')]
    RUBY_DICT = File.join(__dir__, 'ruby.dict')

    def initialize(main_dictionary, *custom_dictionaries, suggestions_size: 0)
      @suggestions_size = suggestions_size
      FFI::Hunspell.directories = HUNSPELL_DIRS << File.dirname(main_dictionary)
      @dictionary = FFI::Hunspell.dict(File.basename(main_dictionary))

      [RUBY_DICT, *custom_dictionaries].flat_map { |path| File.read(path).split("\n") }
                                       .compact
                                       .map { |line| line.gsub(/\s*\#.*$/, '') }
                                       .reject(&:empty?)
                                       .map { |line| line.split(/\s*:\s*/, 2) }
                                       .each do |word, example|
        example ? @dictionary.add_with_affix(word, example) : @dictionary.add(word)
      end
    rescue ArgumentError
      puts "Unable to find dictionary #{main_dictionary}"
      exit(2)
    end

    def correct?(word)
      parts = word.split('-')
      if parts.size == 1
        alterations = [word]
        alterations << word.capitalize unless word.capitalize == word
        alterations << word.upcase unless word.upcase == word
        
        alterations.any?{ |w| dictionary.check?(w) }
      else
        dictionary.check?(word) || parts.all? { |part| correct?(part) }
      end
    end

    def suggest(word)
      @suggestions_size.positive? ? dictionary.suggest(word).first(@suggestions_size) - [word, word.capitalize] : []
    end
  end
end

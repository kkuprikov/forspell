# frozen_string_literal: true

require 'ffi/hunspell'

module Forspell
  class Speller
    attr_reader :dictionaries

    HUNSPELL_DIRS = ["#{__dir__}/dictionaries"].freeze

    def initialize(dictionary_name:, custom_dictionaries:)
      FFI::Hunspell.directories = HUNSPELL_DIRS
      @dictionaries = [FFI::Hunspell.dict(dictionary_name)]

      custom_dictionaries.map { |path| File.read(path)&.split("\n") }
                         .flatten
                         .compact
                         .map { |line| line.gsub(/\s*\#.*$/, '') }
                         .reject(&:empty?)
                         .map { |line| line.split(/\s*:\s*/, 2) }
                         .each do |word, example|
        example ? @dictionaries.first.add_with_affix(word, example) : @dictionaries.first.add(word)
      end
    rescue ArgumentError
      puts "Unable to find the dictionary #{dictionary_name} in any of the directories"
      exit(2)
    end

    def correct?(word)
      dictionaries.any? { |dict| dict.check?(word) }
    end

    def suggest(word)
      dictionaries.map { |dict| dict.suggest(word) }.flatten.first(3)
    end
  end
end

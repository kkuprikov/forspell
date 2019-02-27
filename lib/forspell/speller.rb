# frozen_string_literal: true

require 'ffi/hunspell'

module Forspell
  class Speller
    attr_reader :dictionaries

    HUNSPELL_DIRS = ["#{__dir__}/dictionaries"].freeze

    def initialize(dictionary_name:, custom_dictionary_paths:, ruby_dictionary_path:)
      FFI::Hunspell.directories = HUNSPELL_DIRS
      @dictionaries = [FFI::Hunspell.dict(dictionary_name)]
      dictionary_inputs = File.read(ruby_dictionary_path)&.split("\n")
      if custom_dictionary_paths
        dictionary_inputs += custom_dictionary_paths.map do |path|
          File.read(path)&.split("\n")
        end.flatten
      end

      dictionary_inputs.compact
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

# frozen_string_literal: true

require 'kramdown'
require 'kramdown-parser-gfm'

require_relative'./base_loader'
require_relative'../kramdown/filtered_hash'

module Forspell::Loaders
  class MarkdownLoader < BaseLoader
    attr_reader :result, :errors

    def initialize(input: nil, file: nil, parser: 'GFM')
      @file = file
      @custom_dictionary = []
      @input = input || IO.read(file)
      @result = []
      @errors = []
      @values = []
      @parser = parser
    end

    def process
      document = Kramdown::Document.new(@input, input: @parser)
      tree = Forspell::Kramdown::FilteredHash.new.convert(document.root, document.options)

      return self unless tree

      extract_values(tree)

      locations_with_words = @values.group_by { |res| res[:location] }.transform_values do |v|
        filter_code_objects(v.map { |e| e[:value] }.reduce(:+))
      end

      locations_with_words.each_pair do |location, words|
        next if words.empty?

        words.each do |word|
          @result << Word.new(@file, location || 0, word)
        end
      end
    rescue RuntimeError => e
      @errors << {
        file: @file,
        error_desc: e.inspect
      }
    ensure
      return self
    end

    private

    def extract_values(tree)
      tree[:children].grep(Hash).map do |child|
        if child[:children]
          extract_values(child)
        else
          @values << {
            location: child[:location],
            value: sanitize_value(child[:value])
          }
        end
      end
    end

    def sanitize_value(value)
      return "'" if %i[lsquo rsquo].include?(value)
      return '"' if %i[ldquo rdquo].include?(value)

      value
    end
  end
end

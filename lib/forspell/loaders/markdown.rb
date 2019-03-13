# frozen_string_literal: true

require 'kramdown'
require 'pry'
require 'kramdown-parser-gfm'

require_relative'./base'
require_relative'../kramdown/filtered_hash'

module Forspell::Loaders
  class Markdown < Base
    attr_reader :result, :errors

    PARSER = 'GFM'
    SPEC_MAP = {
      lsquo: "'",
      rsquo: "'",
      ldquo: '"',
      rdquo: '"'
    }.freeze

    def extract_words
      document = Kramdown::Document.new(@input, input: PARSER)
      tree = Forspell::Kramdown::FilteredHash.new.convert(document.root, document.options)
      @comments = []
      chunks = extract_chunks(tree)
      result = []
      return result if chunks.empty?

      group_by_location = chunks.group_by { |res| res[:location] }
                                .transform_values do |lines|
        lines.map { |v| SPEC_MAP[v[:value]] || v[:value] }.join.split(' ')
      end
      group_by_location.each_pair do |location, words|
        words.reject(&:empty?).each { |word| result << Word.new(@file, location || 0, word) }
      end

      result
    rescue RuntimeError => e
      @errors << {
        file: @file,
        error_desc: e.inspect
      }
    end

    private

    def extract_chunks(tree)
      tree[:children].grep(Hash).flat_map do |child|
        if child[:children]
          extract_chunks(child)
        else
          {
            location: child[:location],
            value: child[:value]
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

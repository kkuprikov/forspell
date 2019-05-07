# frozen_string_literal: true

require 'kramdown'
require 'kramdown-parser-gfm'

require_relative './base'

module Forspell::Loaders
  class Markdown < Base
    class FilteredHash
      PERMITTED_TYPES = %i[
        text
        smart_quote
      ].freeze

      def convert(el, options)
        return if !PERMITTED_TYPES.include?(el.type) && el.children.empty?

        hash = { type: el.type }
        hash[:attr] = el.attr unless el.attr.empty?
        hash[:value] = el.value unless el.value.nil?
        hash[:location] = el.options[:location]
        unless el.children.empty?
          hash[:children] = []
          el.children.each { |child| hash[:children] << convert(child, options) }
        end
        hash
      end
    end

    PARSER = 'GFM'
    SPECIAL_CHARS_MAP = {
      lsquo: "'",
      rsquo: "'",
      ldquo: '"',
      rdquo: '"'
    }.freeze

    def extract_words
      document = Kramdown::Document.new(@input, input: PARSER)
      tree = FilteredHash.new.convert(document.root, document.options)
      chunks = extract_chunks(tree)
      result = []
      return result if chunks.empty?

      group_by_location = chunks.group_by { |res| res[:location] }
                                .transform_values do |lines|
        lines.map { |v| SPECIAL_CHARS_MAP[v[:value]] || v[:value] }
          .join.split(%r{[[:punct:]]&&[^-'_./\\:]|\s})
      end
      
      group_by_location.each_pair do |location, words|
        words.reject(&:empty?)
             .each { |word| result << Word.new(@file, location || 0, word) }
      end

      result
    rescue RuntimeError => e
      raise Forspell::Loaders::ParsingError, e.message
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
  end
end

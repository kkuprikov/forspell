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

    def initialize(input: nil, file: nil)
      @file = file
      @input = input
      read_file
      super
    end

    def load_comments
      document = Kramdown::Document.new(@input, input: PARSER)
      @tree = Forspell::Kramdown::FilteredHash.new.convert(document.root, document.options)
      @comments = []
      extract_comments(@tree)
    end

    def load_words
      return if @comments.empty?

      @comments
        .group_by { |res| res[:location] }
        .transform_values do |lines|
          lines.map { |v| SPEC_MAP[v[:value]] || v[:value] }.join.split(' ')
        end.each_pair do |location, words|
          words.reject(&:empty?).each { |word| @result << Word.new(@file, location || 0, word) }
        end
    rescue RuntimeError => e
      @errors << {
        file: @file,
        error_desc: e.inspect
      }
    end

    private

    def extract_comments(tree)
      tree[:children].grep(Hash).each do |child|
        if child[:children]
          extract_comments(child)
        else
          @comments << {
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

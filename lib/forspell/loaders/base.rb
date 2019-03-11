# frozen_string_literal: true

require_relative '../code_objects_filter'

module Forspell::Loaders
  class Base
    attr_reader :result, :errors

    include Forspell::CodeObjectsFilter
    Word = Struct.new(:file, :line, :text)

    def initialize(file: nil, input: nil)
      @file = file
      @result = []
      @errors = []
    end

    def read
      process
      @result
    end

    def process
      read_file
      load_comments
      load_words
      filter
      self
    end

    def read_file
      @input ||= File.read(@file)
    end

    def load_comments
      raise NotImplementedError
    end

    def load_words
      raise NotImplementedError
    end

    def filter
      @result.map! { |word| word[:text] = filter_code_objects(word[:text]).first; word }
             .reject!{ |word| word[:text].nil? || word[:text].empty? }
    end

    %w[load_comments load_words].each do |method_name|
      define_method method_name do
        raise NotImplementedError
      end
    end
  end
end

# frozen_string_literal: true

require 'yard'
require 'yard/parser/ruby/ruby_parser'
require 'rdoc'
require 'pry'
require_relative 'source'

module Forspell::Loaders
  class Ruby < Source
    MAX_COMMENT_LENGTH = 777

    def initialize(file: nil, text: nil)
      super
      @markup = RDoc::Markup.new
      @formatter = RDoc::Markup::ToMarkdown.new
      @formatter.width = MAX_COMMENT_LENGTH
    end

    private

    def comments
      super.reject{ |_, text| text.start_with?('  ') }
    end

    def text(comment)
      @markup.convert(super, @formatter)
    end
  end
end

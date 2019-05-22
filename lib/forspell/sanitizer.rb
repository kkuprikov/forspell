# frozen_string_literal: true

require 'sanitize'
require 'cgi'

module Forspell
  module Sanitizer    
    REMOVE_PUNCT = %r{[!|?|,|(|)|"|;]+}.freeze

    def self.sanitize(input)

      CGI.unescapeHTML(Sanitize.fragment(input, elements: [], remove_contents: true))
         .gsub(REMOVE_PUNCT, '').gsub(%r{[.:]+$}, '')
      end
  end
end

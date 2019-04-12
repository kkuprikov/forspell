# frozen_string_literal: true

require 'sanitize'
require 'cgi'

module Forspell
  module Sanitizer    
    REMOVE_PUNCT = /[[:punct:]&&[^\-\'\_\.]]$/.freeze

    def self.sanitize(input)

      result = CGI.unescapeHTML(Sanitize.fragment(input,
                                         elements: [], remove_contents: true))
                .gsub(REMOVE_PUNCT, '').gsub(/[\!\.\?]{1}$/, '')
      if result.start_with?("'") && result.end_with?("'")
        result[1..-2]
      else
        result
      end
    end
  end
end

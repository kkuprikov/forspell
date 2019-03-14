# frozen_string_literal: true

require 'sanitize'
require 'cgi'

module Forspell
  module CodeObjectsFilter
    CODE_MARKERS = %w[_ # @].freeze
    URI_REGEX = %r{((?:(?:[^ :/?#]+):)(?://(?:[^ /?#]*))(?:[^ ?#]*)(?:\?(?:[^ #]*))?(?:#(?:[^ ]*))?)}.freeze

    WORD = /^\'?[[:upper:]]?[[:lower:]]*[\'\-]?[[:lower:]]*$/.freeze
    CLASSNAME = /^[[:alpha:]]+[[:punct:]]*$/.freeze
    REMOVE_PUNCT = /[[:punct:]&&[^\-\'\.]]/.freeze

    def filter_code_objects(input)
      return '' if CODE_MARKERS.any? { |mark| input.include?(mark) }

      sanitized = sanitize_html(input).gsub(REMOVE_PUNCT, '')

      # checking word pattern,and requiring at least one alphabetical character
      WORD.match(sanitized) && /[[:alpha:]]/.match(sanitized) ? sanitized : ''
    end

    private

    def sanitize_html(input)
      CGI.unescapeHTML Sanitize.fragment(input.gsub(URI_REGEX, ''),
                                         elements: [], remove_contents: true)
    end
  end
end

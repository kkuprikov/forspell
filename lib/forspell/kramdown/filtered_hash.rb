# frozen_string_literal: true

module Forspell
  module Kramdown
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
  end
end

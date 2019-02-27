# frozen_string_literal: true

module Kramdown
  module Converter
    class FilteredHash < HashAst
      PERMITTED_TYPES = %i[
        text
        smart_quote
      ].freeze

      def convert(el)
        return if !PERMITTED_TYPES.include?(el.type) && el.children.empty?

        hash = { type: el.type }
        hash[:attr] = el.attr unless el.attr.empty?
        hash[:value] = el.value unless el.value.nil?
        hash[:location] = el.options[:location]
        unless el.children.empty?
          hash[:children] = []
          el.children.each { |child| hash[:children] << convert(child) }
        end
        hash
      end
    end
  end
end

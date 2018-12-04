module Kramdown
  module Converter
    class FilteredHash < HashAst
      def convert(el)
        return if el.type != :text && el.children.empty?
        hash = {:type => el.type}
        hash[:attr] = el.attr unless el.attr.empty?
        hash[:value] = el.value unless el.value.nil?
        hash[:location] = el.options[:location]
        unless el.children.empty?
          hash[:children] = []
          el.children.each {|child| hash[:children] << convert(child)}
        end
        hash
      end
    end
  end
end
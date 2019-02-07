require 'kramdown'

require_relative'./base_loader'
require_relative'../kramdown/converter/filtered_hash'

class MarkdownLoader < BaseLoader
  attr_reader :result

  def initialize input: nil, file: nil, parser: 'GFM', exclude_path: nil
    @file = file
    @custom_dictionary = []
    @input = input || IO.read(file)
    @result = []
    @values = []
    @parser = parser
  end

  def process
    tree = Kramdown::Document.new(@input, input: @parser).to_filtered_hash
    extract_values(tree)
    
    locations_with_words = @values.group_by{ |res| res[:location] }.transform_values do |v|
      filter_code_objects(v.map{|e| e[:value]}.reduce(:+))
    end

    locations_with_words.each_pair do |location, words|
      @result << {
        file: @file,
        location: location,
        words: words
      } unless words.empty?
    end
    self
  end

  private

  def extract_values tree
    tree[:children].grep(Hash).map do |child| 
      if child[:children]
        extract_values(child)
      else
        @values << {
          # file: @file,
          location: child[:location],
          value: sanitize_value(child[:value])
        }
      end
    end
  end

  def sanitize_value value
    return "'" if %i(lsquo rsquo).include?(value) 
    return '"' if %i(ldquo rdquo).include?(value) 
    value
  end
end
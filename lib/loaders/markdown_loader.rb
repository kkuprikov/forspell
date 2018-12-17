require 'kramdown'

require_relative'./base_loader'
require_relative'../kramdown/converter/filtered_hash'

class MarkdownLoader < BaseLoader
  attr_reader :result

  def initialize input = nil, file: nil, parser: 'GFM', exclude_path: nil
    @custom_dictionary = []
    @input = input || IO.read(file)
    @result = []
    @parser = parser
  end

  def process
    tree = Kramdown::Document.new(@input, input: @parser).to_filtered_hash
    extract_values(tree)
    self
  end

  private

  def extract_values tree
    tree[:children].grep(Hash).map do |child| 
      if child[:children]
        extract_values(child)
      else
        @result << {
          location: child[:location],
          words: sanitize_value(child[:value])
        }
      end
    end
  end

  def sanitize_value value
    filter_code_objects(value)
  end
end
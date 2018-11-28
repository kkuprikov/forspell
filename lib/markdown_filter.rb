require 'kramdown'

class MarkdownFilter
  attr_reader :result

  def initialize input = nil, **params
    @input = input || IO.read(params[:file])
    @result = []
  end

  def process
    tree = Kramdown::Document.new(@input).to_filtered_hash
    @result = extract_values(tree).compact.join(' ')
    self
  end

  private

  def extract_values tree
    tree.dig(:children).select{ |child| child.is_a?(Hash) }.map do |child| 
      child.dig(:children) ? extract_values(child) : @result << sanitize_value(child[:value])
    end
  end

  def sanitize_value value
    # TODO: delete raw URLs or something else
    value
  end
end
require 'kramdown'

class MarkdownFilter
  def initialize input = nil, **params
    @input = input || IO.read(params[:file])
    @values = []
    @parser = params[:parser] || 'Kramdown'
  end

  def process
    tree = Kramdown::Document.new(@input, input: @parser).to_filtered_hash
    extract_values(tree)
    self
  end

  def result
    @values.compact.join(' ')
  end

  private

  def extract_values tree
    tree[:children].select{ |child| child.is_a?(Hash) }.map do |child| 
      child[:children] ? extract_values(child) : @values << sanitize_value(child[:value])
    end
  end

  def sanitize_value value
    # TODO: delete raw URLs or something else
    value
  end
end
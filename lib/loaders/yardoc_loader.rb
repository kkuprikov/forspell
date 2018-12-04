require 'rdoc'
require 'yard'
require 'yard/registry'
require_relative'./base_loader'

class YardocLoader < BaseLoader
  include CodeObjectsFilter

  YARDOC_OPTIONS = %w(--no-output --no-progress --no-stats).freeze

  RDOC_FORMATS = {
    'rd' => RDoc::RD,
    'markdown' => RDoc::Markdown
  }.freeze

  attr_reader :result

  def initialize **params
    @format_class = params[:markup] ? RDOC_FORMATS[params[:markup]] : RDoc::RD
    fail "Unsupported markup format: #{ params[:markup] }" unless @format_class

    @path = params[:file]
  end

  def process
    if @path
     YARD::Registry.load([@path], true) 
    else
      YARD::CLI::Yardoc.new.run(*YARDOC_OPTIONS)
      YARD::Registry.load!
    end

    @result = YARD::Registry.all.map do |object|
      ["#{ object.path }:#{ object.docstring.line_range }", filter_code_objects(extract_text(object.docstring))] unless object.docstring.empty?
    end.compact.to_h

    self
  end

  private

  def extract_text docstring
    @format_class.parse(docstring).parts
      .select{ |part| part.is_a?(RDoc::Markup::Paragraph) }
      .map(&:parts).flatten.join(' ')
  end
end
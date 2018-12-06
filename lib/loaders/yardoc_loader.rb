require 'rdoc'
require 'yard'
require_relative'./base_loader'

class YardocLoader < BaseLoader
  YARDOC_OPTIONS = %w(--no-output --no-progress --no-stats).freeze

  RDOC_FORMATS = {
    'rd' => RDoc::RD,
    'markdown' => RDoc::Markdown
  }.freeze

  DICTIONARY_CLASSES = [
    YARD::CodeObjects::ClassObject,
    YARD::CodeObjects::NamespaceObject
  ]

  attr_reader :result

  def initialize markup: nil, file: nil
    @format_class = markup ? RDOC_FORMATS[markup] : RDoc::RD
    fail "Unsupported markup format: #{ markup }" unless @format_class
    @custom_dictionary = []
    @path = file
  end

  def process
    if @path && !File.directory?(@path)
     YARD::Registry.load([@path], true) 
    elsif !@path
      YARD::CLI::Yardoc.new.run(*YARDOC_OPTIONS)
      YARD::Registry.load!
    else # path is supplied
      current_dir = Dir.pwd
      Dir.chdir @path
      YARD::CLI::Yardoc.new.run(*YARDOC_OPTIONS)
      Dir.chdir current_dir
      YARD::Registry.load!("#{ @path }/.yardoc")
    end

    DICTIONARY_CLASSES.each do |yard_class|
      @custom_dictionary += YARD::Registry.all.grep(yard_class).map{|object| object.name(prefix: true)}
    end    

    @result = YARD::Registry.all.map do |object|
      ["#{object.files.flatten.first} #{ object.path }:#{ object.docstring.line_range }", filter_code_objects(extract_text(object.docstring))] unless object.docstring.empty?
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
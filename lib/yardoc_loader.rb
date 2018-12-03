require 'rdoc'
require 'yard'
require 'yard/registry'

class YardocLoader
  YARDOC_OPTIONS = %w(--no-output --no-progress --no-stats).freeze

  attr_reader :result

  def initialize **params
    @path = params[:file]
  end

  def process
    YARD::CLI::Yardoc.new.run(*YARDOC_OPTIONS) unless @path
    @path ? YARD::Registry.load!(@path) : YARD::Registry.load!

    @result = YARD::Registry.all.map do |object|
      [object.path, object.docstring] unless object.docstring.empty?
    end.compact.to_h

    self
  end
end
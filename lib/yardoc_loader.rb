require 'yard'
require 'yard/registry'

class YardocLoader
  attr_reader :documented_objects

  def initialize **params
    @file = params[:file]
  end

  def process
    #default @file path is current directory
    @file ? YARD::Registry.load!(@file) : YARD::Registry.load!
    @documented_objects = YARD::Registry.all.map do |object|
      [object.path, object.docstring] unless object.docstring.empty?
    end.compact.to_h
  end
end
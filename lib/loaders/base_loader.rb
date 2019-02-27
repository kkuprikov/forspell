# frozen_string_literal: true

require_relative '../code_objects_filter'

class BaseLoader
  include CodeObjectsFilter
  Word = Struct.new(:file, :line, :text)
end

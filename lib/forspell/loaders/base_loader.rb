# frozen_string_literal: true

require_relative '../code_objects_filter'

module Forspell
  class BaseLoader
    include CodeObjectsFilter
    Word = Struct.new(:file, :line, :text)
  end
end

# frozen_string_literal: true

require_relative '../code_objects_filter'

module Forspell::Loaders
  class BaseLoader
    include Forspell::CodeObjectsFilter
    Word = Struct.new(:file, :line, :text)
  end
end

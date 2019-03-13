# frozen_string_literal: true
module Forspell::Loaders
  class C < Source
    def input
      res = super
      res.encode('UTF-8', invalid: :replace, replace: '?') unless res.valid_encoding?
      res
    end
  end
end

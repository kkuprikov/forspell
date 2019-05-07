require 'backports/2.4.0/regexp/match'

module Forspell
  module WordMatcher
    WORD = %r{^
      ([a-z]|[A-Z])      # at least one letter,
      ([[:lower:]])*     # then any number of letters,
      ([\'\-])?          # optional dash/apostrophe,
      ([[:lower:]])*     # another bunch of letters
    $}x

    def self.word? text
      WORD.match?(text)
    end
  end
end
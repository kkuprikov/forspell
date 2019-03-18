module Forspell
  module WordMatcher
    WORD = %r{^
      \'?                      # could start with apostrophe
      ([a-z]|[A-Z])? # at least one letter,
      ([[:lower:]])+   # then any number of letters,
      ([\'\-])?        # optional dash/apostrophe,
      ([[:lower:]])*     # another bunch of letters
      \'?                # could end with apostrophe
    $}x

    def self.word? text
      WORD.match(text) ? true : false
    end
  end
end
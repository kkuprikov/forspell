require_relative '../lib/forspell/word_matcher'
RSpec.describe Forspell::WordMatcher do

  describe '.word?' do
    subject { described_class.word?(word) }

    {
      'word' => true,
      'wrd' => true,
      'Word' => true,
      'WORD' => false,
      'de-facto' => true,
      'de--facto' => false,
      "don't" => true,
      "Don't" => true,
      "don''t" => false,
      "d'on't" => false,
      "D'on't" => false,
      "'bout" => true,
      "doin'" => true,
      'filename.txt' => false,
      'my_variable' => false,
      'MyClassName' => false,
    }.each do |word, result|
      context "when #{word}" do
        let(:word) { word }
        it { is_expected.to eq(result) }
      end
    end
  end
end
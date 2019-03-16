require_relative '../lib/forspell/speller'

RSpec.describe Forspell::Speller do
  let(:custom_dict_path) {File.join(__dir__, 'fixtures', 'custom_dict.dict')}
  let(:speller) { described_class.new('en_US', custom_dict_path) }
  let(:custom_word) { 'somerandomword' }

  subject { speller.correct?(word) }

  describe 'incorrect word' do
    let(:word) { 'notcorrect' }
    specify {is_expected.to be_falsey}
  end

  describe 'custom dictionary word' do
    let(:word) { custom_word }
    specify {is_expected.to be_truthy}
  end
end
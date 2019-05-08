# frozen_string_literal: true

require_relative '../lib/forspell/speller'

RSpec.describe Forspell::Speller do
  let(:custom_dict_path) { File.join(__dir__, 'fixtures', 'custom_dict.dict') }
  let(:speller) { described_class.new('en_US', custom_dict_path, suggestions_size: 3) }

  describe '#suggest' do
    subject { speller.suggest(word) }

    context 'suggestions exist' do
      let(:word) { 'wrd' }
      it { is_expected.not_to be_empty }
    end

    context 'suggestions do not exist' do
      let(:word) { '_______' }
      it { is_expected.to be_empty }
    end

    skip 'word is correct' do
      # won't be called for correct words
      let(:word) { 'word' }
      it { is_expected.not_to be_empty }
    end

    context 'with capital letter' do
      let(:word) { 'Word' }
      it { is_expected.to all match(/^[[:upper:]]/) }
    end
  end

  describe '#correct?' do
    subject { speller.correct?(word) }

    {
      'word' => true,
      'wourd' => false,
      'Word' => true,
      'Gemfile' => true,
      'gemfile' => true,
      'somerandomword' => true,
      'somerandomwords' => true,
      'Somerandomword' => true,
      'Somerandomwords' => true,
      'somerandomwordes' => false,
      'Somerandomwordes' => false,
      'somerandomwor' => false,
      'super' => true,
      'good' => true,
      'super-good' => true,
      'ascii' => true,
      'non-ascii' => true,
      'non-ASCII' => true,
      'super-g00d' => false
    }.each do |word, result|
      context "when #{word}" do
        let(:word) { word }
        it { is_expected.to eq result }
      end
    end
  end
end

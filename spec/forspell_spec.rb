require './lib/forspell'
require 'pry'

RSpec.describe Forspell do
  let(:checker) { described_class.new } # with default en-Us dictionary

  describe '#check_spelling' do
    it 'should work if the spelling of each word is correct' do
      checker.check_spelling('Richard Of York Gave Battle In Vain')
      expect(checker.errors).to be_empty
    end

    it 'should return words with incorrect spelling' do
      checker.check_spelling('s0me r4ndom stuff')
      expect(checker.errors).to contain_exactly('s0me', 'r4ndom')
    end

    it 'should skip class names and special words' do
      checker.check_spelling 'See examples in SomeNamespace::MyAwesomeExamples or AnotherAwesomeExamples, for instance: #ex4mple_load, darlin'
      expect(checker.errors).to contain_exactly('darlin')
    end
  end

  describe '#check_file' do

    subject { checker.errors }
    before { checker.check_file 'spec/fixtures/devise_readme.md' }

    context 'with abbreviations' do
      let(:checker) { described_class.new(params: { with_abbreviations: true }) }

      it 'should check a readme file and return errors' do
        is_expected.not_to be_empty
        is_expected.to include('README')
      end
    end

    context 'without abbreviations' do
      it 'should check a readme file and return errors' do
        ENV['check_abbreviations'] = nil
        is_expected.not_to include('README')
        is_expected.not_to be_empty
      end
    end
  end
end
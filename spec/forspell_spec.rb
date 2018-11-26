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
end
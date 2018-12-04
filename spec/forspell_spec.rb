require 'yard'
require 'pry'
require_relative '../lib/forspell'
require_relative '../lib/loaders/markdown_loader'

RSpec.describe Forspell do
  let(:checker) { described_class.new } # with default en-Us dictionary

  describe '#check_spelling' do
    it 'should work if the spelling of each word is correct' do
      input = 'Richard Of York Gave Battle In Vain'.split(' ')
      expect(checker.check_spelling(input)).to be_empty
    end

    it 'should return words with incorrect spelling' do
      expect(checker.check_spelling('s0me r4ndom stuff'.split(' '))).to contain_exactly('s0me', 'r4ndom')
    end

    describe 'checking readme-s' do
      # let(:filtered_input) { MarkdownLoader.new(file: filepath, parser: 'GFM').process.result }
      let(:checker) { described_class.new(file: filepath, no_output: true) }
      subject { checker.process.result.values.flatten }

      describe 'devise readme' do
        let(:filepath) { 'spec/fixtures/devise_readme.md' }
        specify { 
          # binding.pry
          is_expected.to include('behaviour') }
      end

      describe 'sidekiq readme' do
        let(:filepath) { 'spec/fixtures/sidekiq_readme.md' }
        specify { is_expected.to include('enqueue') }
      end

      describe 'sidekiq readme' do
        let(:filepath) { 'spec/fixtures/sidekiq_readme.md' }
        specify { is_expected.to include('enqueue') }
      end

      describe 'bundler readme' do
        let(:filepath) { 'spec/fixtures/bundler_readme.md' }
        specify { is_expected.to include('prerelease') }
      end
    end
  end

  
end
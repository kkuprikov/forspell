require './lib/forspell'
require './lib/markdown_filter'
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

    describe 'checking real docs' do
      let(:filtered_input) { MarkdownFilter.new(file: filepath, parser: 'GFM').process.result }
      subject { checker.check_spelling(filtered_input) }

      describe 'devise readme' do
        let(:filepath) { 'spec/fixtures/devise_readme.md' }
        specify { is_expected.to include('behaviour') }
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
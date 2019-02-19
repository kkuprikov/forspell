require 'yard'
require 'pry'
require_relative '../lib/forspell'
require_relative '../lib/loaders/markdown_loader'

RSpec.describe Forspell do
  let(:checker) { described_class.new(path: '') } # with default en-Us dictionary

  describe '#check_spelling' do
    it 'should work if the spelling of each word is correct' do
      input = %w[Richard Of York Gave Battle In Vain]
      expect(checker.check_spelling(input)).to be_empty
    end

    it 'should return words with incorrect spelling' do
      expect(checker.check_spelling(%w[s0me r4ndom stuff])).to contain_exactly('s0me', 'r4ndom')
    end

    describe 'checking readme-s errors' do
      # let(:filtered_input) { MarkdownLoader.new(file: filepath, parser: 'GFM').process.result }
      let(:checker) { described_class.new(path: filepath, no_output: true) }
      subject { checker.process.result.map { |res| res[:errors] }.flatten }

      describe 'devise readme' do
        let(:filepath) { 'spec/fixtures/devise_readme.md' }
        specify do
          is_expected.to include('behaviour')
        end
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

    context 'with fixtured grouped examples' do
      subject { described_class.new(path: '').check_spelling(input) }

      data = YAML.load_file 'spec/fixtures/examples.yml'
      data.each_with_index do |spec_hash, index|
        describe "example #{index}" do
          let(:input) { spec_hash['words'] }
          specify { is_expected.to contain_exactly(*spec_hash['errors']) }
        end
      end
    end
  end
end

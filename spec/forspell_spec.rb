require './lib/forspell'
require './lib/markdown_filter'
require 'pry'

RSpec.describe Forspell do
  let(:checker) { described_class.new } # with default en-Us dictionary

  describe '#check_spelling' do
    it 'should work if the spelling of each word is correct' do
      input = 'Richard Of York Gave Battle In Vain'
      expect(checker.check_spelling(input)).to be_empty
    end

    it 'should return words with incorrect spelling' do
      expect(checker.check_spelling('s0me r4ndom stuff')).to contain_exactly('s0me', 'r4ndom')
    end

    describe 'checking readme-s' do
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

  describe 'check_docs' do

    subject { checker.check_docs(docs_input) }
    describe 'test docs input' do
      let(:docs_input) { 
        {
        'MyClass#my_method' => '@params some params \n This method has some test behavior', 
        'MyClass#another_method' => '' 
        }
      }

      specify do 
        is_expected.to be_a Hash
        expect(subject.keys).to contain_exactly('MyClass#my_method')
        expect(subject['MyClass#my_method']).to contain_exactly('params')
      end
    end
  end
end
require_relative '../../lib/forspell/loaders/markdown'
require_relative 'shared_examples'

RSpec.describe Forspell::Loaders::Markdown do

  describe 'markdown files' do
    
    let(:loader) { described_class.new(file: path, text: nil) }
    let(:words) { loader.read }
    
    subject { words.map(&:text) }
    
    describe 'code blocks' do
      locations_with_words = { 1 => %w[This is an example of codeblock] }

      path = File.join(__dir__, '..', 'fixtures', 'code_blocks.md')

      subject { described_class.new(file: path, text: nil).read }
      it_should_behave_like 'comment loader', locations_with_words, path
    end

    describe 'inline code' do
      locations_with_words = {
        1 => %w[This is an example of inline code lines],
        2 => %w[starting from here],
        3 => %w[The end],
       }

      path = File.join(__dir__, '..', 'fixtures', 'inline_code.md')

      subject { described_class.new(file: path, text: nil).read }
      it_should_behave_like 'comment loader', locations_with_words, path
    end

    describe 'inline code mixed with code blocks' do
      locations_with_words = { 1 => %w[plain text isn't] }

      path = File.join(__dir__, '..', 'fixtures', 'code_mixed.md')

      subject { described_class.new(file: path, text: nil).read }
      it_should_behave_like 'comment loader', locations_with_words, path
    end
  end
end
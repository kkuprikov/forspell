require_relative '../../lib/forspell/loaders/markdown'
require_relative 'shared_examples'

RSpec.describe Forspell::Loaders::Markdown do

  describe 'markdown files' do
    
    let(:loader) { described_class.new(file: path, text: nil) }
    let(:words) { loader.read }
    
    
    subject { described_class.new(file: path, text: nil).read }
    
    describe 'code blocks' do
      let(:locations_with_words) { { 1 => %w[This is an example of codeblock] } }

      let(:path) { File.join(__dir__, '..', 'fixtures', 'code_blocks.md') }

      
      it_behaves_like 'a comment loader'
    end

    describe 'with inline code' do
      let(:locations_with_words) {{
        1 => %w[This is an example of inline code lines],
        2 => %w[starting from here],
        3 => %w[The end],
       }}

      let(:path) { File.join(__dir__, '..', 'fixtures', 'inline_code.md') }

      it_behaves_like 'a comment loader'
    end

    describe 'with inline code mixed with code blocks' do
      let(:locations_with_words) { { 1 => %w[plain text isn't] } }

      let(:path) { File.join(__dir__, '..', 'fixtures', 'code_mixed.md') }

      it_behaves_like 'a comment loader'
    end
  end
end
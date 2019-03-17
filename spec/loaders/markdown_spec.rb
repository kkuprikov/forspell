require_relative '../../lib/forspell/loaders/markdown'

RSpec.describe Forspell::Loaders::Markdown do

  describe 'markdown files' do
    
    let(:loader) { described_class.new(file: path, text: nil) }
    let(:words) { loader.read }
    
    subject { words.map(&:text) }
    
    describe 'code blocks' do
      let(:path) { File.join __dir__, '..', 'fixtures', 'markdown_with_code_blocks.md' }
      specify { is_expected.to contain_exactly(*%w[This is an example of codeblock]) }
    end

    describe 'inline code' do
      let(:path) { File.join __dir__, '..', 'fixtures', 'markdown_with_inline_code.md' }
      specify { is_expected.to contain_exactly(*%w[This is an example of inline code lines starting from here The end]) }
    end

    describe 'inline code mixed with code blocks' do
      let(:path) { File.join __dir__, '..', 'fixtures', 'code_mixed.md' }
      specify { is_expected.to contain_exactly(*%w[plain text isn't]) }
    end
  end
end
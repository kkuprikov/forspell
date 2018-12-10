require './lib/loaders/markdown_loader'
require 'pry'

RSpec.describe MarkdownLoader do
  describe 'git flavored markdown parsing' do
    subject { described_class.new(file: filepath, parser: 'GFM').process.result.first[:words] }
    
    context 'with code blocks' do
      let(:filepath) { 'spec/fixtures/markdown_with_code_blocks.md' }
      
      it 'should not contain plain text' do 
        expect(subject).not_to include 'code' 
      end
    end

    context 'with inline code' do
      let(:filepath) { 'spec/fixtures/markdown_with_inline_code.md' }
      
      specify { is_expected.not_to include 'code' }
    end

    describe 'mixed inline code and blocks' do
      let(:filepath) { 'spec/fixtures/code_mixed.md' }

      specify { is_expected.not_to include 'code' }
      specify { is_expected.to include 'plain' }
    end

    describe 'devise readme' do
      let(:filepath) { 'spec/fixtures/devise_readme.md' }
      specify { is_expected.not_to include 'http' }
    end
  end
end
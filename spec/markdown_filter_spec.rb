require './lib/markdown_filter'
require 'pry'

RSpec.describe MarkdownFilter do 
  describe 'process' do
    subject { described_class.new(file: filepath).process.result }
    
    context 'with code blocks' do
      let(:filepath) { 'spec/fixtures/markdown_with_code_blocks.md' }
      
      specify { is_expected.not_to include 'piece of code' }
    end

    context 'with inline code' do
      let(:filepath) { 'spec/fixtures/markdown_with_inline_code.md' }
      
      specify { is_expected.not_to include 'This is code' }
    end

    describe 'mixed inline code and blocks' do
      let(:filepath) { 'spec/fixtures/code_mixed.md' }

      specify { is_expected.not_to include 'code' }
      specify { is_expected.to include 'plain text' }
    end
  end
end
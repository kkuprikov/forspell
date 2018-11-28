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

    describe 'real docs' do
      let(:filepath) { 'spec/fixtures/devise_readme.md' }

      it 'should not include any code' do
        
      end
    end
  end
end
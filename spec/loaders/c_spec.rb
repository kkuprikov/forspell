require_relative '../../lib/forspell/loaders/c'

RSpec.describe Forspell::Loaders::C do

  describe 'C/C++ files' do
    
    let(:loader) { described_class.new(file: path, text: nil) }
    let(:words) { loader.read }
    
    subject { words.map(&:text) }
    
    describe 'C' do
      let(:path) { File.join __dir__, '..', 'fixtures', 'example_module.c' }
      specify { is_expected.to include(*%w[This software is licensed as described in the file]) }
      specify { is_expected.to include(*%w[appends a string to the linked list]) }
    end

    describe 'C++' do
      let(:path) { File.join __dir__, '..', 'fixtures', 'example_module.cxx' }
      specify { is_expected.to include(*%w[The contents of this file are subject to the Mozilla Public License Version]) }
      specify { is_expected.to include(*%w[read magic number]) }
    end
  end
end
require 'pry'
require_relative '../../lib/forspell/loaders/ruby'

RSpec.describe Forspell::Loaders::Ruby do

  let(:path) { File.join __dir__, '..', 'fixtures', 'example_module.rb' }

  it 'should load words from ruby comments in file' do
    loader = described_class.new(file: path, text: nil)
    words = loader.read
    expect(words).not_to be_empty
  end
end
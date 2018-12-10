require './lib/loaders/yardoc_loader'
require 'pry'

RSpec.describe YardocLoader do 
  subject { described_class.new(file: filename).process.result.first }

  describe 'ruby file' do
    let(:filename) { 'spec/fixtures/example.rb' }
    it 'should load words with location' do
      expect(is_expected).is_a? Array
      expect(subject[:words]).to include('process')
    end
  end
end
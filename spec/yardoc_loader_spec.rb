require './lib/loaders/yardoc_loader'
require 'pry'

RSpec.describe YardocLoader do
  subject { described_class.new(file: filename).process.result }

  describe 'ruby file' do
    let(:filename) { 'spec/fixtures/example_module.rb' }
    it 'should load accessors with custom docstring' do
      expect(subject.find { |elem| elem[:object] == 'Sidekiq::Logging#test' }[:words]).to include('erraccessor')
      expect(subject.find { |elem| elem[:object] == 'Sidekiq::Logging#test=' }[:words]).to include('erraccessor')
    end

    it 'should skip attr accessors without custom docstring' do
      expect(subject.find { |elem| elem[:object] == 'Sidekiq::Logging#wont_show' }).to be_nil
    end

    it 'should skip any alias method' do
      expect(subject.find { |elem| elem[:object] == 'Sidekiq::Logging#test?' }).to be_nil
      expect(subject.find { |elem| elem[:object] == 'Sidekiq::Logging#wont_show?' }).to be_nil
    end
  end
end

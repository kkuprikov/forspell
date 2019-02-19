require_relative '../lib/loaders/file_loader'

RSpec.describe FileLoader do
  describe 'including path' do
    subject { described_class.new(path: '.', include_paths: include_paths, exclude_paths: exclude_paths).process.result }

    describe 'correct behavior' do
      let(:include_paths) { ['lib'] }
      let(:exclude_paths) { ['spec'] }
      it 'should contain only files in lib' do
        expect(subject.all? { |file| file.start_with? './lib' }).to be_truthy
      end
    end
  end
end

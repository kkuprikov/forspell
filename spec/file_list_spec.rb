require_relative '../lib/forspell/file_list'

RSpec.describe Forspell::FileList do
  describe 'including path' do
    subject { described_class.new(paths: paths, exclude_paths: exclude_paths) }

    describe 'correct behavior' do
      let(:paths) { ['lib'] }
      let(:exclude_paths) { ['spec'] }
      it 'should contain only files in lib' do
        subject.each do |file| 
          expect(file.start_with? 'lib').to be_truthy
        end
      end
    end
  end
end

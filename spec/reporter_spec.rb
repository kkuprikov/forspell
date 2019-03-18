require_relative '../lib/forspell/reporter'
require_relative '../lib/forspell/loaders/base'

RSpec.describe Forspell::Reporter do

  let(:reporter) { described_class.new(logfile: STDOUT, verbose: false, format: 'readable') }
  let(:word) { Forspell::Loaders::Word.new('file.rb', 5, 'typo') }
  let(:error) { [word, ['type']] }

  describe '#error' do
    it 'should add error with suggestions' do
      reporter.error(*error)
      
    end
  end
end
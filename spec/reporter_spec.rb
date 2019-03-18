require_relative '../lib/forspell/reporter'
require_relative '../lib/forspell/loaders/base'
require_relative 'shared_examples'
require 'yaml'
require 'fakefs/spec_helpers'

RSpec.describe Forspell::Reporter do
  include FakeFS::SpecHelpers

  let(:reporter) { described_class.new(logfile: logfile, verbose: verbose, format: format) }
  let(:file) { 'file.rb' }
  let(:word) { Forspell::Loaders::Word.new(file, 5, 'typo') }
  let(:error) { [word, ['type']] }
  let(:error_data) { [{file: file, line: 5, text: 'typo', suggestions: ['type']}] }

  let(:format) { 'readable' }
  let(:logfile) { 'log.out' }
  let(:verbose) { false }

  before do
    FakeFS do
      FileUtils.touch logfile
    end
    reporter.file(file)
  end

  after do
    FakeFS.deactivate!
  end

  describe '#parsing_error' do
    it 'should output parsing error' do
      reporter.parsing_error('message')
      expect(File.read(logfile)).to eq("Parsing error in #{file}: message\n")
    end
  end

  describe '#path_load_error' do
    it 'should output parsing error' do
      reporter.path_load_error(file)
      expect(File.read(logfile)).to eq("Path not found: #{file}\n")
    end
  end

  describe '#error' do
    let(:printed_output) { "#{word.file}:#{word.line}: \e[31m#{word.text}\e[0m (suggestions: type)\n" }
    
    it_behaves_like 'a single error reporter'
  end

  describe '#report' do
    context 'JSON format' do
      let(:format) { 'json' }
      let(:printed_output) { error_data.to_json + "\n" }

      it_behaves_like 'an error reporter'
    end

    context 'YAML format' do
      let(:format) { 'yaml' }
      let(:printed_output) { error_data.to_yaml }

      it_behaves_like 'an error reporter'
    end

    context 'dictionary format' do
      let(:format) { 'dictionary' }
      let(:printed_output) { "\# #{file}\n\e[31mtypo\e[0m\n" }

      it_behaves_like 'an error reporter'
    end
  end
end
require 'securerandom'
require_relative '../lib/forspell/file_list'

RSpec.describe Forspell::FileList do
  let(:uuid) { SecureRandom.uuid }
  subject { described_class.new(paths: paths, exclude_paths: exclude_paths).each.to_a }

  before do
    FileUtils.mkdir_p "tmp_#{uuid}/bar"
    FileUtils.touch "tmp_#{uuid}/bar.rb"
    FileUtils.touch "tmp_#{uuid}/bar.md"
    FileUtils.touch "tmp_#{uuid}/biz.md"
    FileUtils.touch "tmp_#{uuid}/bar/baz.rb"
    FileUtils.touch "tmp_#{uuid}/bar/baz.md"
  end

  after do
    FileUtils.rm_r "tmp_#{uuid}", secure: true
  end

  describe 'loading files from folders, plus another files' do

    let(:paths) { %W[tmp_#{uuid}/bar tmp_#{uuid}/bar.md] }
    let(:exclude_paths) { [] }

    it { is_expected.to contain_exactly(*%W[tmp_#{uuid}/bar/baz.rb tmp_#{uuid}/bar/baz.md tmp_#{uuid}/bar.md]) }
  end

  describe 'excluding files' do
    context 'with different extensions' do
      let(:paths) { %W[tmp_#{uuid}/bar/baz.rb tmp_#{uuid}/bar/baz.md] }
      let(:exclude_paths) { %W[tmp_#{uuid}/bar/baz.rb] }

      it { is_expected.to contain_exactly("tmp_#{uuid}/bar/baz.md") }
    end

    context 'with same extension' do
      let(:paths) { %W[tmp_#{uuid}/bar.md tmp_#{uuid}/biz.md] }
      let(:exclude_paths) { %W[tmp_#{uuid}/bar.md] }

      it { is_expected.to contain_exactly("tmp_#{uuid}/biz.md") }
    end
  end

  describe 'excluding folders' do
    context 'when excluding subdirectory' do
      let(:paths) { %W[tmp_#{uuid}] }
      let(:exclude_paths) { %W[tmp_#{uuid}/bar] }

      it { is_expected.to contain_exactly(*%W[tmp_#{uuid}/bar.rb tmp_#{uuid}/bar.md tmp_#{uuid}/biz.md]) }
    end

    context 'when include == exclude' do
      let(:paths) { %W[tmp_#{uuid}] }
      let(:exclude_paths) { %W[tmp_#{uuid}] }

      it { is_expected.to be_empty }
    end
  end

  describe 'non-existing paths' do
    let(:paths) { %W[tmp_#{uuid}/foo2] }
    let(:exclude_paths) { %W[tmp_#{uuid}/bar] }
    subject { described_class.new(paths: paths, exclude_paths: exclude_paths).each }

    it { is_expected.to raise_error(Forspell::FileList::PathLoadError, "tmp_#{uuid}/foo2") }
  end
end

require 'pp'
require 'fakefs/spec_helpers'
require 'fileutils'
require_relative '../lib/forspell/file_list'

RSpec.describe Forspell::FileList do
  include FakeFS::SpecHelpers
  subject { described_class.new(paths: paths, exclude_paths: exclude_paths).each.to_a }

  before do
    FakeFS.with_fresh do
      FileUtils.mkdir_p 'foo/bar'
      FileUtils.touch 'foo/bar.rb'
      FileUtils.touch 'foo/bar.md'
      FileUtils.touch 'foo/biz.md'
      FileUtils.touch 'foo/bar/baz.rb'
      FileUtils.touch 'foo/bar/baz.md'
    end
  end

  describe 'loading files from folders, plus another files' do
    let(:paths) { ['foo/bar', 'foo/bar.md'] }
    let(:exclude_paths) { [] }

    it { is_expected.to contain_exactly(*%w[/foo/bar/baz.rb /foo/bar/baz.md foo/bar.md]) }

  end

  describe 'excluding files' do
    context 'with different extensions' do
      let(:paths) { %w[foo/bar/baz.rb foo/bar/baz.md] }
      let(:exclude_paths) { %w[foo/bar/baz.rb] }

      it { is_expected.to contain_exactly('foo/bar/baz.md') }
    end

    context 'with same extension' do
      let(:paths) { %w[foo/bar.md foo/biz.md] }
      let(:exclude_paths) { %w[foo/bar.md] }

      it { is_expected.to contain_exactly('foo/biz.md') }
    end
  end

  describe 'excluding folders' do
    context 'when excluding subdirectory' do
      let(:paths) { %w[foo] }
      let(:exclude_paths) { %w[foo/bar] }

      it { is_expected.to contain_exactly(*%w[/foo/bar.rb /foo/bar.md /foo/biz.md]) }
    end

    context 'when include == exclude' do
      let(:paths) { %w[foo] }
      let(:exclude_paths) { %w[foo] }

      it { is_expected.to be_empty }
    end
  end

  describe 'non-existing paths' do
    let(:paths) { %w[foo/foo2] }
    let(:exclude_paths) { %w[foo/bar] }
    subject { described_class.new(paths: paths, exclude_paths: exclude_paths).each }

    it { is_expected.to raise_error(Forspell::FileList::PathLoadError, 'foo/foo2') }
  end
end

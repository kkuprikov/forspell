# frozen_string_literal: true

require_relative '../../lib/forspell/loaders/ruby'
require_relative 'shared_examples'

RSpec.describe Forspell::Loaders::Ruby do
  subject { described_class.new(file: path, text: nil).read }

  let(:locations_with_words) { { 
                           1 => ['true'],
                           12 => %w[Provide a call method that returns the formatted message],
                           34 => %w[If we're using a wrapper class like use the wrapped],
                           35 => %w[attribute to expose the underlying thing],
                           58 => %w[don't want to close testing's logging],
                           70 => %w[This reopens logfiles in the process that have been rotated],
                           71 => %w[using without copytruncate or similar tools],
                           72 => %w[File object is considered for reopening if it is],
                           76 => %w[Returns the number of files reopened],
                           109 => %w[not much we can do],
                           114 => %w[is disabled will only work with Class pass to enable] } }

  let(:path) { File.join(__dir__, '..', 'fixtures', 'example_module.rb') }

  it_behaves_like 'a comment loader'
end

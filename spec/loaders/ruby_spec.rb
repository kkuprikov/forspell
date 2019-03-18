# frozen_string_literal: true

require_relative '../../lib/forspell/loaders/ruby'
require_relative 'shared_examples'

RSpec.describe Forspell::Loaders::Ruby do
  subject { described_class.new(file: path, text: nil).read }

  let(:locations_with_words) { { 1 => ['true'],
                           9 => ['erraccessor'],
                           15 => ['erralias'],
                           19 => %w[If we're using a wrapper class like use the],
                           20 => %w[attribute to expose the underlying thing],
                           26 => %w[This reopens logfiles in the process that have been rotated],
                           27 => %w[using copytruncate or similar tools],
                           28 => %w[object is considered for reopening if it is],
                           29 => %w[opened with the and flags],
                           30 => %w[the current open file handle does not match its original open path],
                           31 => %w[unbuffered far as userspace buffering goes not],
                           32 => %w[Returns the number of files reopened],
                           65 => %w[not much we can do],
                           70 => %w[is disabled will only work with Class pass to enable] } }

  let(:path) { File.join(__dir__, '..', 'fixtures', 'example_module.rb') }

  it_behaves_like 'a comment loader'
end

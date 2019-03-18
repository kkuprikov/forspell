require 'yaml'
require_relative '../lib/forspell/sanitizer'

RSpec.describe Forspell::Sanitizer do
  describe '#sanitize' do
    let(:input) {'example with <tt>need to filter that</tt>\
     <p>*.asd</p> <dd>!@$#%@%SDF413ef#$&%&</dd> tags'}

    subject { described_class.sanitize(input).gsub(/\s+/, ' ') }

    specify { is_expected.to eq("example with tags") }
  end
end

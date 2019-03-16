require 'yaml'
require_relative '../lib/forspell/sanitizer'

class TestClass
  include Forspell::Sanitizer

  def initialize
    @custom_dictionary = []
  end
end

RSpec.describe TestClass do
  describe 'sanitize html tags' do
    let(:input) {'example with <tt>need to filter that</tt>\
     <p>*.asd</p> <dd>!@$#%@%SDF413ef#$&%&</dd> tags'}

    subject { described_class.new.sanitize(input).gsub(/\s+/, ' ') }

    specify { is_expected.to eq("example with tags") }
  end
end

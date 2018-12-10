require 'pry'
require 'yaml'
require_relative '../lib/code_objects_filter'

class TestClass
  include CodeObjectsFilter
  
  def initialize
    @custom_dictionary = []
  end
end

RSpec.describe TestClass do
  describe 'split input to correct words' do
    subject { described_class.new.filter_code_objects(input) }

    context 'with fixture examples' do
      data = YAML.load_file 'spec/fixtures/examples.yml'
      data.each_with_index do |spec_hash, index|
        describe "example #{ index }" do
          let(:input) { spec_hash['paragraph'] }
          specify { is_expected.to contain_exactly(*spec_hash['words']) }
        end
      end
    end
  end
end
# frozen_string_literal: true

require_relative '../../lib/forspell/loaders/c'
require_relative 'shared_examples'

RSpec.describe Forspell::Loaders::C do
  subject { described_class.new(file: path, text: nil).read }

  describe 'C' do
    let(:locations_with_words) {
      {
        8 => %w[Copyright C Daniel Stenberg et al],
        10 => %w[This software is licensed as described in the file which],
        11 => %w[you should have received as part of this distribution The terms],
        12 => %w[are also available at],
        14 => %w[You may opt to use copy modify merge publish distribute sell],
        15 => %w[copies of the Software and permit persons to whom the Software is],
        16 => %w[furnished to do so under the terms of the file],
        18 => %w[This software is distributed on an basis],
        19 => %w[either express or implied],
        29 => %w[The last files should be],
        32 => %w[appends a string to the linked list This function can be],
        33 => %w[used as an initialization function as well as an append function],
        62 => %w[be nice and clean up resources]
      } }

    let(:path) { File.join(__dir__, '..', 'fixtures', 'example_module.c') }

    it_behaves_like 'a comment loader'
  end

  describe 'C++' do
    let(:locations_with_words) {
      { 2 => ['Version'],
        4 => %w[Copyright C Németh László],
        6 => %w[The contents of this file are subject to the Mozilla Public License Version],
        7 => %w[the License you may not use this file except in compliance with],
        8 => %w[the License You may obtain a copy of the License at],
        11 => %w[Software distributed under the License is distributed on an basis],
        12 => %w[either express or implied See the License],
        13 => %w[for the specific language governing rights and limitations under the],
        14 => ['License'],
        16 => %w[Hunspell is based on which is Copyright C Kevin Hendricks],
        18 => %w[Contributors David Einstein Davide Prina Giuseppe Modugno],
        19 => %w[Gianluca Turconi Simon Brouwer Noll János Bíró],
        20 => %w[Goldman Eleonóra Sarlós Tamás Bencsáth Boldizsár Halácsy Péter],
        21 => %w[Dvornik László Gefferth András Nagy Viktor Varga Dániel Chris Halls],
        22 => %w[Rene Engelhard Bram Moolenaar Dafydd Jones Harri Pitkänen],
        24 => %w[Alternatively the contents of this file may be used under the terms of],
        25 => %w[either the General Public License Version or later the or],
        26 => %w[the Lesser General Public License Version or later the],
        27 => %w[in which case the provisions of the or the are applicable instead],
        28 => %w[of those above If you wish to allow use of your version of this file only],
        29 => %w[under the terms of either the or the and not to allow others to],
        30 => %w[use your version of this file under the terms of the indicate your],
        31 => %w[decision by deleting the provisions above and replace them with the notice],
        32 => %w[and other provisions required by the or the If you do not delete],
        33 => %w[the provisions above a recipient may use your version of this file under],
        34 => %w[the terms of any one of the the or the],
        81 => %w[read magic number],
        88 => %w[check encryption],
        103 => %w[read record count],
        119 => %w[read codes],
        190 => %w[add last odd byte],
        217 => ['escape'] } }

    let(:path) { File.join(__dir__, '..', 'fixtures', 'example_module.cxx') }

    it_behaves_like 'a comment loader'
  end
end

RSpec.shared_examples 'comment loader' do |locations_with_words, path|
  it 'should contain all the words from comments' do
    comment_words = locations_with_words.flat_map do |location, words|
      words.map { |w| Forspell::Loaders::Word.new(path, location, w) }
    end
    is_expected.to contain_exactly(*comment_words)
  end
end

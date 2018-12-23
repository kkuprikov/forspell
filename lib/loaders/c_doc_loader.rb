require_relative 'ruby_doc_loader'

class CDocLoader < RubyDocLoader
  def initialize file: nil
    super
    @parser_class = YARD::Parser::C::CParser
  end

  def load_comments
    @comments = @parser_class.new(File.read(@file), @file).parse
      .grep(YARD::Parser::C::Comment)
      .map{ |comment| [:comment, comment.source, [comment.line]] }
  end
end
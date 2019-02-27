# frozen_string_literal: true

require 'rdoc'
require 'yard'
require 'pry'
require_relative './base_loader'

module Forspell::Loaders
  class YardocLoader < BaseLoader
    YARDOC_OPTIONS = %w[--no-output --no-progress --no-stats].freeze

    RDOC_FORMATS = {
      'rd' => RDoc::RD,
      'markdown' => RDoc::Markdown
    }.freeze

    DICTIONARY_CLASSES = [
      YARD::CodeObjects::ClassObject,
      YARD::CodeObjects::NamespaceObject
    ].freeze

    attr_reader :result

    def initialize(markup: nil, file: nil, exclude_path: nil)
      @format_class = markup ? RDOC_FORMATS[markup] : RDoc::RD
      raise "Unsupported markup format: #{markup}" unless @format_class

      @custom_dictionary = []
      @path = file
      @exclude_path = exclude_path
    end

    def process
      if @path && !File.directory?(@path)
        YARD::Registry.load([@path], true)
      elsif !@path
        YARD::CLI::Yardoc.new.run(*YARDOC_OPTIONS)
        YARD::Registry.load!
      else # path is supplied
        current_dir = Dir.pwd
        Dir.chdir @path
        YARD::CLI::Yardoc.new.run(*YARDOC_OPTIONS)
        Dir.chdir current_dir
        YARD::Registry.load!("#{@path}/.yardoc")
      end

      DICTIONARY_CLASSES.each do |yard_class|
        @custom_dictionary += YARD::Registry.all.grep(yard_class).map { |object| object.name(prefix: true) }
      end

      @result = YARD::Registry.all.map do |object|
        next if object.docstring.empty? || skip_method?(object) || skip_by_path?(object)

        {
          file: object.file,
          object: object.path,
          location: object.docstring.line,
          words: filter_code_objects(extract_text(object.docstring))
        }
      end.compact

      self
    end

    private

    def extract_text(docstring)
      @format_class.parse(docstring).parts
                   .select { |part| part.is_a?(RDoc::Markup::Paragraph) }
                   .map(&:parts).flatten.join(' ')
    end

    def skip_method?(object)
      return false unless object.is_a? YARD::CodeObjects::MethodObject

      result = object.is_alias? ||
               result = object.reader? && object.docstring.to_s =~ /^Returns the value of attribute #{ object.name.to_s }$/ ||
                        object.writer? && object.docstring.to_s =~ /^Sets the attribute #{ object.name.to_s.chop }$/
      result ? true : false
    end

    def skip_by_path?(object)
      return false unless @exclude_path

      !Dir.glob("#{@exclude_path}/**/#{object.file.split('/').last}").empty?
    end
  end
end

# frozen_string_literal: true

module Forspell::Loaders
  class FileLoader
    EXTENSION_GLOBS = %w[
      rb
      c
      cpp
      cxx
      md
    ].freeze
    attr_reader :result

    def initialize(path: '.', exclude_paths: [])
      @path = path
      @exclude_paths = exclude_paths
    end

    def process
      files_to_exclude = @exclude_paths.flat_map do |exclude_path|
        generate_file_paths @path, exclude_path
      end || []

      @result = Dir.glob("#{@path}/**/*.{#{EXTENSION_GLOBS.join(',')}}") - files_to_exclude
      self
    end

    private

    def generate_file_paths(root, path)
      relative_path = path.include?('/') ? path.split('/')[1..-1].join('/') : path
      if File.directory?(path)
        Dir.glob("#{root}/**/#{relative_path}/**/*.{#{EXTENSION_GLOBS.join(',')}}")
      else
        Dir.glob("#{root}/**/#{relative_path}")
      end
    end
  end
end

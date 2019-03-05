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

    def initialize(paths:, exclude_paths:)
      @paths = paths
      @exclude_paths = exclude_paths
    end

    def process
      to_process = @paths.flat_map do |path|
        generate_file_paths path
      end

      to_exclude = @exclude_paths.flat_map do |path|
        generate_file_paths path
      end || []

      @result = (to_process - to_exclude).map{ |path| path.gsub('//', '/')}

      self
    end

    private

    def generate_file_paths(path)
      if File.directory?(path)
        Dir.glob("#{path}/**/*.{#{EXTENSION_GLOBS.join(',')}}")
      else
        path
      end
    end
  end
end

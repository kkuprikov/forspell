# frozen_string_literal: true

module Forspell
  class FileList
    include Enumerable

    EXTENSION_GLOBS = %w[
      rb
      c
      cpp
      cxx
      md
    ].freeze

    def initialize(paths:, exclude_paths:)
      @paths = paths
      @exclude_paths = exclude_paths
    end

    def each(&block)
      to_process = @paths.flat_map do |path|
        generate_file_paths path
      end.compact

      to_exclude = @exclude_paths.flat_map do |path|
        generate_file_paths path
      end || []

      (to_process - to_exclude).map{ |path| path.gsub('//', '/')}
        .each(&block)
    end

    private

    def generate_file_paths(path)
      if File.directory?(path)
        Dir.glob("#{path}/**/*.{#{EXTENSION_GLOBS.join(',')}}")
      elsif File.exists? path
        path
      else
        puts "Path not found: #{ path }"
      end
    end
  end
end

# frozen_string_literal: true

module Forspell
  class FileList
    include Enumerable
    class PathLoadError < StandardError; end

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
      to_process = @paths.flat_map(&method(:expand_paths))

      to_exclude = @exclude_paths.flat_map(&method(:expand_paths))

      (to_process - to_exclude).map{ |path| path.gsub('//', '/')}
        .each(&block)
    end

    private

    def expand_paths(path)
      if File.directory?(path)
        Dir.glob(File.join("#{path}", '**', "*.{#{EXTENSION_GLOBS.join(',')}}"))
      elsif File.exists? path
        path
      else
        raise PathLoadError, path
      end
    end
  end
end

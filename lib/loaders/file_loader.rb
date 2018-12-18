require 'pry'

class FileLoader
  EXTENSION_GLOBS = %w(
    rb
    c
    cpp
    cxx
    md
  )
  attr_reader :result

  def initialize path: '.', include_paths: [], exclude_paths: []
    @path = path
    @exclude_paths = exclude_paths
    @include_paths = include_paths
  end

  def process
    files_to_include = @include_paths.map do |include_path| 
      generate_file_paths @path, include_path
    end.reduce(:+)

    files_to_exclude = @exclude_paths.map do |exclude_path| 
      generate_file_paths @path, exclude_path
    end.reduce(:+)

    @result = files_to_include.empty? ? Dir.glob("#{ @path }/**/*.{#{ EXTENSION_GLOBS.join(',') }}") : files_to_include
    @result -= files_to_exclude
        
    self
  end

  private

  def generate_file_paths root, directory
    Dir.glob("#{ root }/**/#{ directory }/**/*.{#{ EXTENSION_GLOBS.join(',') }}")
  end
end
require_relative 'lib/forspell/cli'

PATHS_TO_SPELLCHECK = %w[lib/ README.md].freeze

desc 'Run self spellchecking'
task :spellcheck do |t|
  Forspell::CLI.new(PATHS_TO_SPELLCHECK).call
end

begin
  require 'rspec/core/rake_task'

  RSpec::Core::RakeTask.new(:spec)

  task :spec
rescue LoadError
  puts 'No spec available'
  exit(1)
end

task default: [:spec, :spellcheck]
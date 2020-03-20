require 'bundler/gem_tasks'

require 'rspec/core/rake_task'
require 'rubocop/rake_task'
require 'reek/rake/task'
require 'inch/rake'

require 'forspell/cli'
require 'mdl'

RSpec::Core::RakeTask.new(:spec)
RuboCop::RakeTask.new(:rubocop)
Reek::Rake::Task.new
Inch::Rake::Suggest.new

PATHS_TO_SPELLCHECK = ['.'].freeze
PATHS_FOR_MDL = ['README.md', Dir.glob('docs/**/*.md')].flatten.freeze

desc 'Run self spellchecking'
task :spellcheck do |_task|
  puts 'Run forspell checker...'
  Forspell::CLI.new(PATHS_TO_SPELLCHECK).call
rescue SystemExit => e
  if e.status.zero?
    puts 'Everything is ok.'
  else
    exit e.status
  end
end

desc 'Run markdown linter'
task :mdl do |_task|
  puts 'Run MDL linter...'
  MarkdownLint.run(PATHS_FOR_MDL)
rescue SystemExit => e
  if e.status.zero?
    puts 'Everything is ok.'
  else
    exit e.status
  end
end

task default: %i[rubocop reek spec spellcheck mdl]

require "bundler/gem_tasks"
require "rspec/core/rake_task"
require "yard"
require "yard/rake/yardoc_task"

RSpec::Core::RakeTask.new(:spec) do |t|
  t.verbose = false
end

YARD::Rake::YardocTask.new do |t|
  t.files   = ['lib/**/*.rb', '-', 'README.md', 'LICENSE.txt', 'CODE_OF_CONDUCT.md']
  t.options = ['--private', '--protected']
  t.stats_options = ['--list-undoc']
end

task :default => :spec

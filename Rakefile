#!/usr/bin/env rake

require "rspec/core/rake_task"

include Rake::DSL

load "lib/tasks/rspec.rake"

$LOAD_PATH.unshift File.expand_path("lib", File.dirname(__FILE__))

require "acceptance_test/version"
require "gemspec_deps_gen/gemspec_deps_gen"
require "acceptance_test/gen_tool"
require "acceptance_test/diff_tool"

version = AcceptanceTest::VERSION
project_name = File.basename(Dir.pwd)

task :gen do
  generator = GemspecDepsGen.new

  generator.generate_dependencies "spec", "#{project_name}.gemspec.erb", "#{project_name}.gemspec"
end

task :build => :gen do
  system "gem build #{project_name}.gemspec"
end

task :install => :build do
  system "gem install #{project_name}-#{version}.gem"
end

task :uninstall do
  system "gem uninstall #{project_name}"
end

task :release => :build do
  system "gem push #{project_name}-#{version}.gem"
end

RSpec::Core::RakeTask.new do |task|
  task.pattern = 'spec/**/*_spec.rb'
  task.verbose = false
end

# task :fix_debug do
#   system "mkdir -p $GEM_HOME/gems/debugger-ruby_core_source-1.2.3/lib"
#   system "cp -R ~/debugger-ruby_core_source/lib $GEM_HOME/gems/debugger-ruby_core_source-1.2.3"
# end

task :gen_steps do
  if ARGV.size < 2
    puts "Usage: rake gen_steps <file_name.feature>"
  else
    ARGV.shift

    file_name = ARGV.shift

    GenTool.instance.generate_steps file_name
  end
end

task :gen_feature do
  if ARGV.size < 2
    puts "Usage: rake gen_feature <file_name_with_steps_spec.rb>"
  else
    ARGV.shift

    file_name = ARGV.shift

    GenTool.instance.generate_feature file_name
  end
end

task :diff_steps do
  if ARGV.size < 3
    puts "Usage: rake diff_steps <file_name.feature> <file_name_with_steps_spec.rb>"
  else
    ARGV.shift

    source = ARGV.shift
    target = ARGV.shift

    # source = "spec/features/search_with_pages.feature"
    # target = "spec/acceptance/search_with_steps_spec.rb"

    # source = ARGV.shift
    # target = source.gsub("features", "acceptance").gsub(".feature", "_spec.rb")

    DiffTool.instance.diff source, target
  end
end

task :turnip do
  # result = system "CONFIG_FILE=workspace/wikipedia/acceptance_config.yml rspec -r acceptd/acceptance_config -r turnip/rspec workspace/wikipedia/features/search_with_drivers.feature"
  result = system "CONFIG_FILE=spec/wikipedia/acceptance_config.yml rspec -r acceptance_test/acceptance_config -r turnip/rspec spec/wikipedia/features/search_with_drivers.feature"

  puts result
end
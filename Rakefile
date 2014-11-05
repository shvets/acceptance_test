#!/usr/bin/env rake

require "rspec/core/rake_task"

include Rake::DSL

load "lib/tasks/rspec.rake"

$LOAD_PATH.unshift File.expand_path("lib", File.dirname(__FILE__))

require "acceptance_test/version"
require "gemspec_deps_gen/gemspec_deps_gen"

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

task :steps_gen do
  if ARGV.size < 2
    puts "Usage: rake steps_gen <file_name.feature>"
  else
    ARGV.shift

    file_name = ARGV.shift

    StepsGenerator.instance.generate file_name
  end
end

task :steps_diff do
  if ARGV.size < 3
    puts "Usage: rake steps_diff <file_name.feature> <file_name_spec.rb>"
  else
    ARGV.shift

    file_name1 = ARGV.shift
    file_name2 = ARGV.shift

#    StepsGenerator.instance.generate file_name

    phrases1 = []

    keywords_exp1 = /^(Given|When|Then|And|But)/

    File.open(file_name1).each_line do |line|
      line = line.strip

      if line !~ /^#/ and line =~ keywords_exp1
        word = line.scan(keywords_exp1)[0][0]

        phrases1 << line[word.size..-1].strip
      end
    end

    phrases2 = []

    keywords_exp2 = /step\s+('|")(.*)('|")/

    File.open(file_name2).each_line do |line|
      line = line.strip

      if line !~ /^#/ and line =~ keywords_exp2
        phrases2 << line.scan(keywords_exp2)[0][1]
      end
    end

    phrases1.each_with_index do |phrase, index|
      phrase1 = phrase.clone.gsub("\"", "'")
      phrase2 = phrases2[index]

      params = phrase2.gsub(/:\w+\S/).to_a

      params.each do |param|
        new_param = param.gsub(":", "")

        phrase1.gsub!(%r{<#{new_param}>}, param)
      end

      # p phrase1
      params.each do |param|
        phrase1.gsub!(/(\w|\s)*/, param)
      end
      # p phrase1

      if phrase1 != phrase2
        puts "Fail:"
        puts "  {#{phrase}}"
        puts "  {#{phrases2[index]}}"
      else
        # puts "OK:"
        # puts "  {#{phrase}}"
        # puts "  {#{phrases2[index]}}"
      end
    end
  end
end
require 'rspec'
require 'gnawrnip'

namespace :rspec do

  def create_spec_task name, paths
    pattern = paths.collect {|path| "#{path}/**/*.feature" }

    rspec_opts = "--color -r turnip/rspec"

    desc 'Run turnip acceptance tests'
    RSpec::Core::RakeTask.new(name) do |t|
      t.pattern = pattern
      t.rspec_opts = rspec_opts
    end
  end

  create_spec_task :"acceptance", %w(spec/features)

end
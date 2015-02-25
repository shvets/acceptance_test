require 'singleton'
require 'yaml'
require 'csv'
require 'active_support/core_ext/hash'
require 'acceptance_test'

require 'turnip/capybara'
require 'gnawrnip'

class AcceptanceConfig
  include Singleton

  def configure app_name=nil
    @app_name = app_name

    load_support_code "spec"

    acceptance_test = AcceptanceTest.instance

    #acceptance_test.enable_external_source data_reader # enable external source for gherkin

    RSpec.configure do |config|
       config_file = acceptance_config_file(app_name)
       acceptance_config = config_file ? HashWithIndifferentAccess.new(YAML.load_file(config_file)) : {}

      acceptance_test.configure(acceptance_config)

      acceptance_test.configure_turnip 'tmp/report.html', "test"

      config.before(:type => :feature) do |example|
        acceptance_test.setup page, example.metadata
      end

      config.after(:type => :feature) do |example|
        extra_metadata = {}

        extra_metadata[:screenshot_url_base] = acceptance_config[:screenshot_url_base] if acceptance_config[:screenshot_url_base]

        acceptance_test.teardown page, example.metadata.merge(extra_metadata), example.exception
      end
    end
  end

  def app_name
    ENV['APP_NAME'].nil? ? @app_name : ENV['APP_NAME']
  end

  def environment
    ENV['ACCEPTANCE_ENV'].nil? ? "development" : ENV['ACCEPTANCE_ENV']
  end

  def acceptance_config_file app_name
    ENV['CONFIG_FILE'] ? File.expand_path(ENV['CONFIG_FILE']) : detect_file("acceptance_config", app_name, ".yml")
  end

  private

  def load_support_code basedir
    target = nil

    ARGV.each do |arg|
      if arg =~ /.*\.feature/
        target = arg
      end
    end

    target = ARGV.last unless target

    if File.directory?(target)
      target_dir = target
    else
      target_dir = File.dirname(target)
    end

    support_dir = "#{target_dir}/../support"

    $: << File.expand_path("#{basedir}/support")
    $: << File.expand_path(support_dir)

    Dir.entries("#{support_dir}/steps").each do |name|
      require "steps/#{File.basename(name)}" unless [".", ".."].include? name
    end
 end

  def detect_file dir, app_type, ext
    path1 = "#{dir}/#{app_type}-#{environment}#{ext}"
    path2 = "#{dir}/#{app_type}#{ext}"

    full_path = File.expand_path(path1)

    File.exist?(full_path) ? full_path : File.expand_path(path2)
  end

  def data_reader
    lambda do |source_path|
      ext = File.extname(source_path)

      if ext == '.csv'
        CSV.read(File.expand_path(source_path))
      elsif ext == '.yml'
        YAML.load_file(File.expand_path(source_path))
      end
    end
  end

end


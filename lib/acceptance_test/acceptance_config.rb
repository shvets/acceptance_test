require 'singleton'
require 'yaml'
require 'csv'
require 'selenium/webdriver'
require 'active_support/core_ext/hash'
require 'acceptance_test'

require 'gnawrnip'

class AcceptanceConfig
  include Singleton

  def configure workspace, params
    @app_name = params[:app_name]

    support_dirs = load_code_from_support workspace
    load_steps support_dirs

    acceptance_test = AcceptanceTest.instance

    if params[:enable_external_source]
      data_reader = params[:data_reader] ? params[:data_reader] : default_data_reader

      acceptance_test.enable_external_source data_reader # enable external source for gherkin
    end

    acceptance_test.ignore_case_in_steps if params[:ignore_case_in_steps]

    acceptance_config = acceptance_config_file ? HashWithIndifferentAccess.new(YAML.load_file(acceptance_config_file)) : {}
    acceptance_test.configure(acceptance_config)

    if block_given?
      yield acceptance_test.config
    end

    RSpec.configure do |config|
      acceptance_test.configure_turnip turnip_report_file, turnip_report_name

      config.before(:type => :feature) do |example|
        acceptance_test.setup page, example.metadata
      end

      config.after(:type => :feature) do |example|
        extra_metadata = {}

        screenshot_url_base = AcceptanceTest.instance.config[:screenshot_url_base]

        extra_metadata[:screenshot_url_base] = screenshot_url_base if screenshot_url_base

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

  def format
    ENV['FORMAT'].nil? ? "xlsx" : ENV['FORMAT']
  end

  def config_dir
    ENV['CONFIG_DIR'] ?  ENV['CONFIG_DIR'] : "acceptance_config"
  end

  def data_dir
    ENV['DATA_DIR'] ?  ENV['DATA_DIR'] : "acceptance_data"
  end

  def results_dir
    ENV['RESULTS_DIR'] ?  ENV['RESULTS_DIR'] : "acceptance_results"
  end

  def acceptance_config_file
    detect_file(config_dir, "#{app_name}.yml")
  end

  def acceptance_data_file name="#{app_name}.#{format}"
    file = detect_file(upload_dir, name)

    File.exist?(file) ? file : detect_file(data_dir, name)
  end

  def acceptance_results_file
    detect_file(results_dir, "#{app_name}.#{format}")
  end

  def turnip_report_file
    File.expand_path("tmp/" + (app_name ? "#{app_name}-acceptance-report.html" : "acceptance-report.html"))
  end

  def turnip_report_name
    "#{app_name[0].upcase+app_name[1..-1]} Acceptance"
  end

  def webapp_url name=:webapp_url
    AcceptanceTest.instance.config[name]
  end

  def screenshots_dir
    AcceptanceTest.instance.config[:screenshots_dir]
  end

  def upload_dir
    AcceptanceTest.instance.config[:upload_dir]
  end

  def upload_dev_dir
    AcceptanceTest.instance.config[:upload_dev_dir]
  end

  def acceptance_results_dir
    AcceptanceTest.instance.config[:results_dir]
  end

  def local_env?
    !!(AcceptanceTest.instance.config[:webapp_url] =~ /localhost/)
  end

  def default_data_reader
    lambda do |source_path|
      path = acceptance_data_file detect_file_from_script(source_path)

      puts "Reading data from: #{path}"

      ext = File.extname(path)

      if ext == '.csv'
        CSV.read(File.expand_path(path))
      elsif ext == '.yml'
        YAML.load_file(File.expand_path(path))
      end
    end
  end

  def detect_file dir, name
    ext = File.extname(name)
    basename = File.basename(name)
    basename = basename[0..basename.size-ext.size-1]

    path1 = "#{dir}/#{basename}-#{environment}#{ext}"
    path2 = "#{dir}/#{basename}#{ext}"

    full_path1 = File.expand_path(path1)
    full_path2 = File.expand_path(path2)

    File.exist?(full_path1) ? full_path1 : full_path2
  end

  def detect_file_from_script source_path
    path = source_path % {acceptance_env: environment, format: format}

    if File.exist? File.expand_path(path)
      path
    else
      dir = File.dirname(source_path)
      name = File.basename(source_path).gsub("-", '')
      source_path = (dir == ".") ? name : "#{dir}/#{name}"

      (source_path % {acceptance_env: '', format: format})
    end
  end

  private

  def load_code_from_support basedir
    support_dirs = []

    Dir["#{basedir}/**/*"].each do |name|
      if File.exist?(name) && File.basename(name) == 'support'
        support_dirs << name
        $LOAD_PATH << name
      end
    end

    support_dirs
  end

  def load_steps support_dirs
    support_dirs.each do |support_dir|
      Dir["#{support_dir}/**/steps/*_steps.rb"].each do |name|
        ext = File.extname(name)

        require name[support_dir.length+1..name.length-ext.length-1]
      end
    end
  end

end

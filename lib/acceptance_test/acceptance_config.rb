require 'singleton'
require 'yaml'
require 'csv'
require 'selenium/webdriver'
require 'active_support/core_ext/hash'
require 'acceptance_test'

require 'gnawrnip'

class AcceptanceConfig
  include Singleton

  def configure workspace, app_name=nil
    @app_name = app_name

    load_support_code workspace

    acceptance_test = AcceptanceTest.instance

    acceptance_test.enable_external_source data_reader # enable external source for gherkin

    acceptance_config = acceptance_config_file ? HashWithIndifferentAccess.new(YAML.load_file(acceptance_config_file)) : {}

    acceptance_test.configure(acceptance_config)

    RSpec.configure do |config|
      configure_turnip

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

  def format
    ENV['FORMAT'].nil? ? "xlsx" : ENV['FORMAT']
  end

  def acceptance_config_file
    ENV['CONFIG_FILE'] ? File.expand_path(ENV['CONFIG_FILE']) : detect_file("acceptance_config", "#{app_name}.yml")
  end

  def acceptance_data_file name="#{app_name}.#{format}"
    ENV['DATA_DIR'] ? detect_file(ENV['DATA_DIR'], name) : detect_file("acceptance_data", name)
  end

  def acceptance_results_file name="#{app_name}.#{format}"
    ENV['RESULTS_DIR'] ? detect_file(ENV['RESULTS_DIR'], name) : detect_file("acceptance_results", name)
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

  private

  def configure_turnip
    report_file = turnip_report_file(app_name)

    configure_turnip_formatter report_file, app_name

    configure_gnawrnip
  end

  def configure_turnip_formatter report_file, report_name
    require 'turnip_formatter'

    RSpec.configure do |config|
      config.add_formatter RSpecTurnipFormatter, report_file
    end

    TurnipFormatter.configure do |config|
      config.title = "#{report_name[0].upcase+report_name[1..-1]} Acceptance"
    end
  end

  def configure_gnawrnip
    Gnawrnip.configure do |c|
      c.make_animation = true
      c.max_frame_size = 1024 # pixel
    end

    Gnawrnip.ready!
  end

  def turnip_report_file name=nil
    name = ENV['TURNIP_REPORT_PREFIX'] if ENV['TURNIP_REPORT_PREFIX']

    file_name = name.nil? ? "acceptance-report.html" : "#{name}-acceptance-report.html"

    File.expand_path("tmp/#{file_name}")
  end

  def load_support_code basedir
    target = nil

    ARGV.each do |arg|
      if arg =~ /.*\.feature/
        target = arg
      end
    end

    target = ARGV.last unless target

    if target
      if File.directory?(target)
        target_dir = target
      else
        target_dir = File.dirname(target)
      end
    else
      target_dir = basedir
    end

    $: << File.expand_path("#{basedir}/support")

    support_dir = File.expand_path("#{target_dir}/../support")
    support_dir = File.expand_path("#{target_dir}/support") unless File.exist?(support_dir)

    $: << support_dir if File.exist?(support_dir)

    Dir.glob("#{support_dir}/**/steps/*_steps.rb").each do |name|
      ext = File.extname(name)

      require name[support_dir.length+1..name.length-ext.length-1]
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

  def data_reader
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
end

require 'yaml'
require 'singleton'
require 'active_support/core_ext/hash'

class AcceptanceTestBuilder
  include Singleton

  def create project_root, config_name, screenshot_dir
    Capybara.default_driver = :selenium

    ENV['DRIVER'] = 'selenium'

    Capybara.configure do |config|
      config.match = :first

      config.ignore_hidden_elements = false
    end

    project_root = File.expand_path(project_root.to_s)

    config = HashWithIndifferentAccess.new(YAML.load_file(config_name))

    system "mkdir -p #{screenshot_dir}"

    acceptance_test = AcceptanceTest.new project_root, config, screenshot_dir

    ENV['ASSET_HOST'] = acceptance_test.app_host

    puts "Application URL   : #{config[:webapp_url]}"
    puts "Selenium URL      : http://#{config[:selenium_host]}:#{config[:selenium_port]}"
    puts "ENV['DRIVER']     : #{ENV['DRIVER']}" if ENV['DRIVER']
    puts "Default Wait Time : #{Capybara.default_wait_time}"

    acceptance_test
  end

end

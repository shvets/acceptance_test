require 'yaml'
require 'singleton'
require 'active_support/core_ext/hash'

class AcceptanceTestHelper
  include Singleton

  def create_acceptance_test project_root, config_name, screenshot_dir
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
    puts "Selenium URL      : #{config[:selenium_url]}" if config[:selenium_url]
    puts "Default Wait Time : #{Capybara.default_wait_time}"

    acceptance_test
  end

  def create_shared_context acceptance_test, name
    throw "rspec library is not available" unless defined? RSpec

    acceptance_test_lambda = lambda do
      attr_reader :acceptance_test

      before :all do
        @acceptance_test = acceptance_test
      end

      before do
        metadata = RSpec.current_example.metadata

        acceptance_test.before metadata
      end

      after do
        metadata = RSpec.current_example.metadata

        acceptance_test.after metadata, RSpec.current_example.exception, page

        self.reset_session!
      end
    end

    RSpec.shared_context name do
      self.define_singleton_method(:include_context, acceptance_test_lambda)

      include_context
    end
  end

  def metadata_from_scenario scenario
    tags = scenario.source_tag_names.collect { |a| a.gsub("@", '') }

    metadata = {}

    if tags.size > 0
      tag = tags.first.to_sym

      if AcceptanceTest.supported_drivers.include? tag
        metadata[:driver] = tag
      end
    end

    metadata
  end

  def get_localhost
    orig, Socket.do_not_reverse_lookup = Socket.do_not_reverse_lookup, true  # turn off reverse DNS resolution temporarily

    UDPSocket.open do |s|
      s.connect '192.168.1.1', 1
      s.addr.last
    end
  ensure
    Socket.do_not_reverse_lookup = orig
  end

end
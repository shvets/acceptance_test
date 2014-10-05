require 'turnip/define'

# @acceptance_test = AcceptanceTest.new
#
# singleton_class.send :attr_reader, :acceptance_test
#
# step "I am within wikipedia.com" do
#   config_name = File.expand_path("spec/acceptance_config.yml")
#   config = HashWithIndifferentAccess.new(YAML.load_file(config_name))
#
#   WikipediaSteps.acceptance_test.configure config
# end
# attr_reader :acceptance_test

# before do
#   p "before"
#   acceptance_test = AcceptanceTest.new true, rspec_scope
#
#   config_name = File.expand_path("spec/acceptance_config.yml")
#   config = HashWithIndifferentAccess.new(YAML.load_file(config_name))
#
#   acceptance_test.configure config
# end
#
# after do
#   p "after"
# end

module Turnip
  module Define
    def before &block
      send(:define_method, "before",  &block) if block
    end

    def after &block
      send(:define_method, "after",  &block) if block
    end
  end
end

module Turnip
  module RSpec
    module Execute
      def run_before rspec_scope
        self.class.send(:define_method, :rspec_scope, lambda { rspec_scope })

        before
      end

      def run_after
        after
      end
    end

    class << self
      def run(feature_file)
        Turnip::Builder.build(feature_file).features.each do |feature|
          ::RSpec.describe feature.name, feature.metadata_hash do
            rspec_scope = self
            before do
              run_before rspec_scope
              example = Turnip::RSpec.fetch_current_example(self)
              # This is kind of a hack, but it will make RSpec throw way nicer exceptions
              example.metadata[:file_path] ||= feature_file

              feature.backgrounds.map(&:steps).flatten.each do |step|
                run_step(feature_file, step)
              end
            end
            feature.scenarios.each do |scenario|
              instance_eval <<-EOS, feature_file, scenario.line
              describe scenario.name, scenario.metadata_hash do it(scenario.steps.map(&:to_s).join(' -> ')) do
                  scenario.steps.each do |step|
                    run_step(feature_file, step)
                  end
                end
              end
              EOS
            end
            after do
              run_after
            end
          end
        end
      end
    end

  end
end

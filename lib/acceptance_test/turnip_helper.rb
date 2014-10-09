require 'singleton'

require 'turnip/define'

class TurnipHelper
  include Singleton

  def extend_turnip
    turnip_define = Turnip::Define

    turnip_define.class_eval do
      def before &block
        send(:define_method, "before",  &block) if block
      end

      def after &block
        send(:define_method, "after",  &block) if block
      end
    end

    turnip_rspec_execute = Turnip::RSpec::Execute

    turnip_rspec_execute.class_eval do
      def run_before rspec_root
        self.class.send(:define_method, :rspec_root, lambda { rspec_root })

        before
      end

      def run_after rspec_root
        self.class.send(:define_method, :rspec_root, lambda { rspec_root })

        after
      end
    end

    turnip_rspec = Turnip::RSpec

    turnip_rspec.class_eval do
      class << self
        def run(feature_file)
          Turnip::Builder.build(feature_file).features.each do |feature|
            ::RSpec.describe feature.name, feature.metadata_hash do
              rspec_root = self

              before do
                run_before rspec_root
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
                run_after rspec_root
              end
            end
          end
        end
      end
    end
  end

end

require 'singleton'

require 'turnip/define'

class TurnipHelper
  include Singleton

  def build_dynamic_steps page_set, context
    ##self.class.step :enter_word, "I enter word :word"

    turnip_rspec_execute = Turnip::RSpec::Execute

    turnip_rspec_execute.class_eval do
      alias_method :old_run_step, :run_step

      def run_step(feature_file, step)
        begin
          instance_eval <<-EOS, feature_file, step.line
            step(step)
          EOS
        rescue Turnip::Pending => e

          # instance_eval <<-EOS, feature_file, step.line
          #   step(:visit_home_page, "I am on wikipedia.com")
          # EOS

          # page_set.pages.each do |page|
          #   page_set.page_methods(page).each do |method|
          #     context.class.step "I #{method.to_s.gsub('_', ' ')}" do
          #       send method
          #     end
          #
          #     # context.class.step method, "I #{method.to_s.gsub('_', ' ')}"
          #     #
          #     # context.class.step method, "#{method.to_s.gsub('_', ' ')}"
          #   end
          # end

          old_run_step feature_file, step
        end
      end
    end

    if context
      context.class.send(:define_method, :method_missing) do |meth, *args, &block|
        page_set.send meth, *args, &block
      end
    end

    # page_set.pages.each do |page|
    #   page_set.page_methods(page).each do |method|
    #     page_set.class.step "I #{method.to_s.gsub('_', ' ')}" do
    #       send method
    #     end
    #
    #     page_set.class.step "#{method.to_s.gsub('_', ' ')}" do
    #       send method
    #     end
    #   end
    # end
  end

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

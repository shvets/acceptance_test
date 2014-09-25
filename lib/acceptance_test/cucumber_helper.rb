require 'singleton'

require 'cucumber/ast/outline_table'

class CucumberHelper
  include Singleton

  def enable_external_source data
    outline_table = Cucumber::Ast::OutlineTable

    outline_table.class_eval do
      @data = data # class instance variable

      def self.data # access to class instance variable
        @data
      end

      def initialize(raw, scenario_outline)
        new_raw = raw

        name = raw[0][0]

        if name == 'external_source'
          test_name, parameter_name = raw[1][0].split(":")

          puts Cucumber::Ast::OutlineTable.data

          size = Cucumber::Ast::OutlineTable.data[test_name][parameter_name].size

          new_raw = Array.new(size+1) {Array.new(1)}
          new_raw[0][0] = parameter_name

          Cucumber::Ast::OutlineTable.data[test_name][parameter_name].each_with_index do |value, index|
            new_raw[index+1][0] = value
          end
        end

        super(new_raw)

        @scenario_outline = scenario_outline
        @cells_class = Cucumber::Ast::OutlineTable::ExampleRow
        init
      end
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
end

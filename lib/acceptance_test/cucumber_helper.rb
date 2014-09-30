require 'singleton'

require 'cucumber/ast/outline_table'

class CucumberHelper
  include Singleton

  def source_type scenario
    examples(scenario)[0][0][5][0][0]
  end

  def source_path scenario
    examples(scenario)[0][0][5][1][0]
  end

  def set_outline_table scenario, keys, values
    if scenario.kind_of?(Cucumber::Ast::ScenarioOutline) and source_type(scenario) == 'file'
      examples(scenario)[0][0][5] = keys + values
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

  private

  def examples scenario
    scenario.instance_variable_get(:@example_sections)
  end

end

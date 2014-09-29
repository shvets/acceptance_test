require 'singleton'

require 'cucumber/ast/outline_table'

class CucumberHelper
  include Singleton

  def source_type scenario
    examples = scenario.instance_variable_get(:@example_sections)

    examples[0][0][5][0][0]
  end

  def source_path scenario
    examples = scenario.instance_variable_get(:@example_sections)

    examples[0][0][5][1][0]
  end

  def set_outline_table scenario, keys, values
    examples = scenario.instance_variable_get(:@example_sections)

    if source_type(scenario) == 'file'
      examples[0][0][5] = keys + values
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

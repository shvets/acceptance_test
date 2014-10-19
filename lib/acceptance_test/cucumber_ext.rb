class CucumberExt
  def self.metadata_from_scenario scenario
    tags = scenario.source_tag_names.collect { |a| a.gsub("@", '') }

    metadata = {}

    if tags.size > 0
      tag = tags.first.to_sym

      if AcceptanceTest.instance.driver_manager.supported_drivers.include? tag
        metadata[:driver] = tag
      end
    end

    metadata
  end
end
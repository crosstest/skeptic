require 'crosstest/core'
require 'crosstest/psychic'
require 'crosstest/code2doc'
require 'crosstest/skeptic/version'
require 'crosstest/skeptic/errors'

module Crosstest
  class Skeptic
    autoload :Configuration, 'crosstest/skeptic/configuration'
    autoload :ScenarioDefinition, 'crosstest/skeptic/scenario_definition'
    autoload :PropertyDefinition, 'crosstest/skeptic/property_definition'
    autoload :Scenario, 'crosstest/skeptic/scenario'
    autoload :TestStatuses, 'crosstest/skeptic/test_statuses'
    autoload :TestTransitions, 'crosstest/skeptic/test_transitions'
    autoload :TestManifest, 'crosstest/skeptic/test_manifest'
    autoload :Evidence, 'crosstest/skeptic/evidence'
    autoload :Result, 'crosstest/skeptic/result'
    autoload :Spy, 'crosstest/skeptic/spy'
    autoload :Spies, 'crosstest/skeptic/spies'
    autoload :Validation, 'crosstest/skeptic/validation'
    autoload :Validator, 'crosstest/skeptic/validator'
    autoload :ValidatorRegistry, 'crosstest/skeptic/validator_registry'

    class << self
      include Core::Configurable

      def acts_on_scenario(action)
        define_method action do
          scenarios.each do | scenario |
            scenario.public_send(action)
          end
        end
      end
    end

    def initialize(psychic = Psychic.new)
      @psychic = psychic
    end

    def manifest
      Skeptic.configuration.manifest
    end

    def scenarios
      @scenarios ||= build_scenarios
    end

    def scenario(name)
      scenarios.find { |s| s.name == name }
    end

    def scenario_definitions
      manifest.scenario_definitions
    end

    def build_scenarios
      scenario_definitions.map do | scenario_definition |
        scenario_definition.build @psychic
      end
    end

    def summary
      summary_data = ["#{scenarios.size} scenarios"]
      scenarios.group_by(&:status).each do | _status, group |
        # Note: Removes partially verified's parenthetical description
        status_description = group.first.status_description.gsub(/\(.*/, '')
        summary_data << "#{group.size} #{status_description.downcase}"
      end
      summary_data.join("\n  ")
    end

    acts_on_scenario :clear
    acts_on_scenario :exec
  end
end

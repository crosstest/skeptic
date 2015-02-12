require 'rspec/expectations' # exceptions are being stored as classes, so this is needed to load
require 'crosstest/core'
require 'crosstest/psychic'
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
        define_method action do | regex = 'all', options = {} |
          scenarios(regex, options).each do | scenario |
            scenario.public_send(action)
          end
        end
      end

      def acts_on_scenario_with_options(action)
        define_method action do | regex = 'all', options = {} |
          scenarios(regex, options).each do | scenario |
            scenario.public_send(action, options)
          end
        end
      end

      # Registers a {Crosstest::Skeptic::Validator} that will be used during test
      # execution on matching {Crosstest::Skeptic::Scenario}s.
      def validate(desc, scope = { suite: //, scenario: // }, &block)
        fail ArgumentError, 'You must pass block' unless block_given?
        validator = Crosstest::Skeptic::Validator.new(desc, scope, &block)

        Crosstest::Skeptic::ValidatorRegistry.register validator
        validator
      end
    end

    def initialize(psychic = Psychic.new)
      psychic = Psychic.new(psychic) if psychic.is_a? Hash
      @psychic = psychic
    end

    def manifest
      Skeptic.configuration.manifest
    end

    def scenario_definitions
      manifest.scenario_definitions
    end

    def build_scenarios
      scenario_definitions.map do | scenario_definition |
        scenario_definition.build @psychic
      end
    end

    def scenario(name)
      scenarios.find { |s| s.name == name }
    end

    def all_scenarios
      @scenarios ||= build_scenarios
    end

    def select_scenarios(regexp)
      regexp ||= 'all'
      if regexp == 'all'
        return all_scenarios
      else
        selected_scenarios = all_scenarios.find { |c| c.full_name == regexp } ||
                             all_scenarios.select { |c| c.full_name =~ /#{regexp}/i }
      end

      if selected_scenarios.is_a? Array
        selected_scenarios
      else
        [selected_scenarios]
      end
    end

    def scenarios(regexp = 'all', options = {})
      selected_scenarios = select_scenarios regexp
      selected_scenarios.keep_if { |scenario| scenario.failed? == options[:failed] } unless options[:failed].nil?
      selected_scenarios.keep_if { |scenario| scenario.skipped? == options[:skipped] } unless options[:skipped].nil?
      selected_scenarios.keep_if { |scenario| scenario.sample? == options[:samples] } unless options[:samples].nil?
      selected_scenarios
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

    acts_on_scenario_with_options :code2doc
    acts_on_scenario :test
    Scenario::FSM::TRANSITIONS.each do | transition |
      acts_on_scenario transition
    end
  end
end

Crosstest.mutex = Mutex.new

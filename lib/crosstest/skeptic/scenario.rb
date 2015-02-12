require 'benchmark'

# TODO: This class really needs to be split-up - and probably renamed.
#
# There's a few things happening here:
#   There's the "Scenario" - probably better named "Scenario" - this
#   is *what* we want to test, i.e. "Fog - Upload Directory". It should
#   only rely on parsing crosstest.yaml.
#
#   Then there's the "Code Sample" - the code to be tested to verify the
#   scenario. This can probably be moved to Psychic, since Psychic finds
#   and executes the code samples.
#
#   And the result or "State File" - this stores and persists the test
#   results and data captured by spies during test.
#
#   Finally, there's the driver, including the FSM class at the bottom of
#   this file. It's responsible for managing the test lifecycle.

module Crosstest
  class Skeptic
    class Scenario < Crosstest::Core::Dash # rubocop:disable ClassLength
      extend Forwardable
      include Skeptic::TestTransitions
      include Skeptic::TestStatuses
      include Crosstest::Core::FileSystem
      include Crosstest::Core::Logging
      include Crosstest::Core::Util::String
      # View helpers
      include Crosstest::Psychic::Code2Doc::CodeHelper

      field :scenario_definition, ScenarioDefinition
      required_field :psychic, Crosstest::Psychic
      field :vars, Skeptic::TestManifest::Environment, default: {}
      field :code_sample, Psychic::Script
      field :source_file, Pathname

      def_delegators :scenario_definition, :name, :suite, :full_name
      def_delegators :psychic, :basedir, :logger
      # def_delegators :code_sample, :source_file, :absolute_source_file, :source
      def_delegators :evidence, :save
      KEYS_TO_PERSIST = [:last_attempted_action, :last_completed_action, :result,
                         :spy_data, :error, :duration]
      KEYS_TO_PERSIST.each do |key|
        def_delegators :evidence, key.to_sym, "#{key}=".to_sym
      end

      attr_reader :slug

      def initialize(data)
        super
        @slug = slugify(suite, name, psychic.name)
        @evidence_file = Pathname.new(Crosstest.basedir).join('.crosstest', "#{slug}.pstore").expand_path.freeze
      end

      def evidence(initial_data = {})
        @evidence ||= Skeptic::Evidence.load(@evidence_file, initial_data)
      end

      def validators
        Crosstest::Skeptic::ValidatorRegistry.validators_for self
      end

      def code_sample
        self[:code_sample] ||= psychic.script(name)
      rescue Errno::ENOENT
        nil
      end

      def source_file
        return nil unless code_sample

        self[:source_file] ||= Pathname(code_sample)
      end

      def absolute_source_file
        return nil unless code_sample

        code_sample.absolute_source_file
      end

      def source
        return nil unless code_sample

        code_sample.source
      end

      def code2doc(options = {})
        return nil unless code_sample

        doc = code_sample.code2doc(options)
      end

      def detect!
        # fail FeatureNotImplementedError, "Project #{psychic.name} has not been cloned" unless psychic.cloned?
        fail FeatureNotImplementedError, name if source_file.nil?
        self.source_file = Pathname(code_sample)
      rescue Errno::ENOENT
        raise FeatureNotImplementedError, name
      end

      def exec!
        detect!
        evidence.result = run!
      end

      def run!(spies = Crosstest::Skeptic::Spies) # rubocop:disable Metrics/AbcSize
        spies.observe(self) do
          code_sample.env = vars.merge(ENV.to_hash)
          if code_sample.params.is_a? String
            code_sample.params = YAML.load(Psychic::Tokens.replace_tokens(code_sample.params, vars))
          else
            code_sample.params = vars
          end
          execution_result = code_sample.execute(env: vars)
          evidence.result = Skeptic::Result.new(execution_result: execution_result, source_file: source_file.to_s)
        end
        result
      rescue Crosstest::Shell::ExecutionError => e
        execution_error = ExecutionError.new(e)
        execution_error.execution_result = e.execution_result
        evidence.error = Crosstest::Error.formatted_trace(e).join("\n")
        raise execution_error
      rescue => e
        evidence.error = Crosstest::Error.formatted_trace(e).join("\n")
        raise e
      ensure
        save
      end

      def verify!
        validators.each do |validator|
          validation = validator.validate(self)
          status = case validation.result
                   when :passed
                     Core::Color.colorize("\u2713 Passed", :green)
                   when :failed
                     Core::Color.colorize('x Failed', :red)
                     Crosstest.handle_validation_failure(validation.error)
                   else
                     Core::Color.colorize(validation.result, :yellow)
                   end
          info format('%-50s %s', validator.description, status)
        end
      end

      def clear!
        @evidence.clear
        @evidence = nil
      end

      def validations
        return nil if result.nil?
        result.validations
      end
    end
  end
end

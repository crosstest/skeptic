module Omnitest
  class Skeptic
    class Result < Omnitest::Core::Dash
      extend Forwardable
      field :execution_result, Omnitest::Shell::ExecutionResult
      def_delegators :execution_result, :stdout, :stderr, :exitstatus
      field :source_file, Pathname
      field :data, Hash
      field :validations, Hash[String => Validation], default: {}

      def successful?
        execution_result.successful?
      end

      alias_method :success?, :successful?

      def status
        # A feature can be validated by different suites, or manually vs an automated suite.
        # That's why there's a precedence rather than boolean algebra here...
        return 'failed' if validations.values.any? { |v| v.status == :failed }
        return 'passed' if validations.values.any? { |v| v.status == :passed }
        return 'pending' if validations.values.any? { |v| v.status == :pending }
        'skipped'
      end
    end
  end
end

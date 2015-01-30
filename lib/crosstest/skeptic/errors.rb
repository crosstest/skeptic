module Crosstest
  module Skeptic
    # Exception class capturing what caused an scenario to die.
    class ScenarioFailure < TransientFailure; end

    # Exception class capturing what caused a validation to fail.
    class ValidationFailure < TransientFailure
      include ErrorSource
    end

    class FeatureNotImplementedError < StandardError
      def initialize(feature)
        super "Feature #{feature} is not implemented"
      end
    end

    class ScenarioCheckError < StandardError; end
  end
end

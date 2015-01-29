module Crosstest
  module Skeptic
    class Configuration < Crosstest::Core::Dash
      def manifest
        @manifest ||= load_manifest('skeptic.yaml')
      end

      def manifest=(manifest_data)
        if manifest_data.is_a? Skeptic::TestManifest
          @manifest = manifest_data
        else
          @manifest = Skeptic::TestManifest.from_yaml manifest_data
        end
        @manifest
      rescue Errno::ENOENT => e
        raise UserError, "Could not load test manifest: #{e.message}"
      end

      alias_method :load_manifest, :manifest=

      # The callback used to validate code samples that
      # don't have a custom validator.  The default
      # checks that the sample code runs successfully.
      def default_validator_callback
        @default_validator_callback ||= proc do |scenario|
          expect(scenario.result.execution_result.exitstatus).to eq(0)
        end
      end

      def default_validator
        @default_validator ||= Skeptic::Validator.new('default validator', suite: //, scenario: //, &default_validator_callback)
      end

      attr_writer :default_validator_callback

      def register_spy(spy)
        Crosstest::Skeptic::Spies.register_spy(spy)
      end

      def clear
        ValidatorRegistry.clear
      end
    end
  end
end

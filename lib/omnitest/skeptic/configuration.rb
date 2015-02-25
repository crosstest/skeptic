module Omnitest
  class Skeptic
    class Configuration < Omnitest::Core::Dash
      field :seed, Integer, default: Process.pid # or Random.new_seed
      field :manifest, TestManifest
      field :manifest_file, Pathname, default: 'skeptic.yaml'

      def manifest
        self[:manifest] ||= load_manifest
      end

      def manifest_file=(file)
        self[:manifest] = nil
        self[:manifest_file] = file
      end

      def load_manifest
        ENV['SKEPTIC_SEED'] = seed.to_s
        Skeptic::TestManifest.from_yaml manifest_file
      rescue Errno::ENOENT => e
        raise UserError, "Could not load test manifest: #{e.message}"
      end

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
        Omnitest::Skeptic::Spies.register_spy(spy)
      end

      def clear
        ValidatorRegistry.clear
      end
    end
  end
end

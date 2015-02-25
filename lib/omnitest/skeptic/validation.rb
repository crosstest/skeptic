module Omnitest
  class Skeptic
    class Validation < Omnitest::Core::Dash
      # TODO: Should we have (expectation) 'failed' vs (unexpected) 'error'?
      ALLOWABLE_STATES = %w(passed pending failed skipped)

      required_field :status, Symbol
      field :error, Object
      field :error_source, Object

      def status=(state)
        state = state.to_s
        fail invalidate_state_error unless ALLOWABLE_STATES.include? state
        super
      end

      ALLOWABLE_STATES.each do |state|
        define_method "#{state}?" do
          status == state?
        end
      end

      def error_source?
        !error_source.nil?
      end

      def to_hash(*args)
        self.error_source = error.error_source if error.respond_to? :error_source
        super
      end

      protected

      def invalidate_state_error(state)
        ArgumentError.new "Invalid status: #{state}, should be one of #{ALLOWABLE_STATES.inspect}"
      end
    end
  end
end

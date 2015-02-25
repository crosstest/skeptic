module Omnitest
  class Skeptic
    class PropertyDefinition < Omnitest::Core::Dash # rubocop:disable ClassLength
      field :required, Object, default: false
      field :default, String
    end
  end
end

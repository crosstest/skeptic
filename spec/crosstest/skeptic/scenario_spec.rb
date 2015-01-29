module Crosstest
  module Skeptic
    describe Scenario do
      subject(:scenario) do
        project = Crosstest::Psychic.new name: 'some_sdk', cwd: 'spec/fixtures'
        Fabricate(:scenario_definition, name: 'factorial', vars: {}).build(project)
      end

      describe '#exec' do
        it 'executes the scenario and returns itself' do
          expect(scenario.exec).to be_an_instance_of Scenario
          expect(scenario.exec).to eq(scenario)
        end

        it 'stores the result' do
          evidence = scenario.exec
          result = evidence.result
          expect(result).to be_an_instance_of Skeptic::Result
        end
      end
    end
  end
end

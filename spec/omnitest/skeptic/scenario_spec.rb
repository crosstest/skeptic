module Omnitest
  class Skeptic
    describe Scenario do
      subject(:scenario) do
        project = Omnitest::Psychic.new name: 'some_sdk', cwd: 'spec/fixtures'
        Fabricate(:scenario_definition, name: 'factorial', vars: {}).build(project)
      end

      describe '#detect' do
        pending 'finds a script for the scenario'
      end

      describe '#check' do
        pending 'checks the script complies with static rules'
      end

      describe '#prepare' do
        pending 'meets unmet dependencies'
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

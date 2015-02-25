require 'spec_helper'

module Omnitest
  RSpec.describe Skeptic do
    before(:each) do | _example |
      write_file 'skeptic.yaml', <<-eos
---
suites:
  Execution:
    samples:
      - success
      - failure
eos
      write_file 'success.rb', 'puts "foo"; exit 0'
      write_file 'failure.rb', 'puts "bar"; exit 1'

      Skeptic.configure do | config |
        config.manifest_file = File.expand_path('skeptic.yaml', current_dir)
      end

      subject.clear
    end

    let(:psychic) { Psychic.new(cwd: current_dir) }
    subject { described_class.new(psychic) }

    describe '#scenarios' do
      it 'returns the list of all scenarios' do
        scenarios = subject.scenarios
        expect(scenarios).to_not be_empty
        scenarios.each do | scenario |
          expect(scenario).to be_an_instance_of Skeptic::Scenario
        end
      end
    end

    describe '#prepare' do
      let(:satisifed_dependency) { double('satisifed_dependency', met?: true) }
      let(:unsatisifed_dependency) { double('unsatisifed_dependency', met?: false) }

      pending 'meets unmet dependencies' do
        scenarios = subject.scenarios
        expect(satisifed_dependency).to_not receive(:meet)
        expect(satisifed_dependency).to receive(:meet)
        subject.prepare
      end
    end

    describe '#exec' do
      it 'calls exec on each scenario and stores an execution result' do
        scenarios = subject.scenarios
        results = scenarios.map(&:result)
        expect(results).to all(be nil)
        subject.exec
        results = scenarios.map(&:result)
        expect(results).to all(be_an_instance_of Skeptic::Result)
        expect(scenarios.map(&:status_description)).to all(eq 'Executed')

        expect(subject.scenario('success').result).to be_successful
        expect(subject.scenario('failure').result).to_not be_successful
        puts subject.summary
      end
    end
  end
end

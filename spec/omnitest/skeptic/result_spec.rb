require 'spec_helper'

module Omnitest
  class Skeptic
    describe Result do
      describe '#status' do
        context 'mixed pass/fail' do
          let(:subject) do
            Omnitest::Skeptic::Result.new(
              validations: {
                'max' => { result: 'passed' },
                'omnitest' => { result: 'failed', error: 'foo!' }
              }
            ).status
          end
          it 'reports the failed status' do
            is_expected.to eq('failed')
          end
        end
        context 'mix passed/pending/skipped' do
          let(:subject) do
            Omnitest::Skeptic::Result.new(
              validations: {
                'max' => { result: 'passed' },
                'omnitest' => { result: 'pending' },
                'john doe' => { result: 'skipped' }
              }
            ).status
          end
          it 'reports the passed status' do
            is_expected.to eq('passed')
          end
        end
        context 'mix pending/skipped' do
          let(:subject) do
            Omnitest::Skeptic::Result.new(
              validations: {
                'max' => { result: 'pending' },
                'omnitest' => { result: 'pending' },
                'john doe' => { result: 'skipped' }
              }
            ).status
          end
          it 'reports the pending status' do
            is_expected.to eq('pending')
          end
        end
      end
    end
  end
end

require 'crosstest/skeptic'

module Crosstest
  class Skeptic
    class BaseCLI < Crosstest::Core::CLI
      attr_accessor :psychic, :skeptic

      no_commands do
        def update_config!
          runner_opts = { cwd: Dir.pwd, cli: shell, parameters: options.parameters }
          runner_opts.merge!(Crosstest::Core::Util.symbolized_hash(options))
          @psychic = Crosstest::Psychic.new(runner_opts)
          @skeptic = Crosstest::Skeptic.new(@psychic)
        end
      end
    end

    class CLI < BaseCLI
      # The maximum number of concurrent instances that can run--which is a bit
      # high
      MAX_CONCURRENCY = 9999

      desc 'test [SCENARIO|REGEXP|all]',
           'Test (clone, bootstrap, exec, and verify) one or more scenarios'
      long_desc <<-DESC
        The scenario states are in order: cloned, bootstrapped, executed, verified.
        Test changes the state of one or more scenarios executes
        the actions for each state up to verify.
      DESC
      method_option :concurrency,
                    aliases: '-c',
                    type: :numeric,
                    lazy_default: MAX_CONCURRENCY,
                    desc: <<-DESC.gsub(/^\s+/, '').gsub(/\n/, ' ')
          Run a test against all matching instances concurrently. Only N
          instances will run at the same time if a number is given.
        DESC
      method_option :log_level,
                    aliases: '-l',
                    desc: 'Set the log level (debug, info, warn, error, fatal)'
      method_option :skeptic,
                    aliases: '-s',
                    desc: 'The Skeptic test manifest file',
                    default: 'skeptic.yaml'
      method_option :test_dir,
                    aliases: '-t',
                    desc: 'The Crosstest test directory',
                    default: 'tests/crosstest'
      def test(regex = 'all')
        update_config!
        action_options = options.dup
        skeptic.public_send(:test, regex, action_options)
      end

      {
        detect: 'Find sample code that matches a test scenario. ' \
                      'Attempts to locate a code sample with a filename that the test scenario name.',
        exec: 'Change instance state to executed. ' \
                      'Execute the code sample and capture the results.',
        verify: 'Change instance state to verified. ' \
                      'Assert that the captured results match the expectations for the scenario.',
        clear: 'Clear stored results for the scenario. ' \
                     'Delete all stored results for one or more scenarios'
      }.each do |action, short_desc|
        desc(
          "#{action} [SCENARIO|REGEXP|all]",
          short_desc
        )
        long_desc <<-DESC
          The scenario states are in order: cloned, bootstrapped, executed, verified.
          Change one or more scenarios from the current state to the #{action} state. Actions for all
          intermediate states will be executed.
        DESC
        method_option :concurrency,
                      aliases: '-c',
                      type: :numeric,
                      lazy_default: MAX_CONCURRENCY,
                      desc: <<-DESC.gsub(/^\s+/, '').gsub(/\n/, ' ')
            Run a #{action} against all matching instances concurrently. Only N
            instances will run at the same time if a number is given.
          DESC
        method_option :log_level,
                      aliases: '-l',
                      desc: 'Set the log level (debug, info, warn, error, fatal)'
        method_option :file,
                      aliases: '-f',
                      desc: 'The Crosstest project set file',
                      default: 'crosstest.yaml'
        method_option :skeptic,
                      aliases: '-s',
                      desc: 'The Skeptic test manifest file',
                      default: 'skeptic.yaml'
        method_option :test_dir,
                      aliases: '-t',
                      desc: 'The Crosstest test directory',
                      default: 'tests/crosstest'
        define_method(action) do |regex = 'all'|
          update_config!
          action_options = options.dup
          skeptic.public_send(action, regex, action_options)
        end
      end
    end
  end
end

RSpec.describe 'ruby' do
  context 'without bundler' do
    before(:each) do
      write_file 'hello_world.rb', <<-eos
        puts "Hello, world!"
      eos
    end
  end

  context 'with bundler' do
    before(:each) do
      write_file 'Gemfile', <<-eos
      source 'https://rubygems.org'

      gem 'thor'
      eos

      write_file 'hello_world.rb', <<-eos
      class CLI < Thor
        default_task :hello

        desc 'hello', 'says hi'
        def hello
          say 'Hello, world!'
        end
      end
      eos
    end

    include_examples 'says hello'
  end
end

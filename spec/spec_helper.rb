require 'bundler/setup'

require 'simplecov'
require 'codecov'
require 'pry'

SimpleCov.minimum_coverage 95
SimpleCov.formatter = SimpleCov::Formatter::Codecov unless ENV['CODECOV_TOKEN'].nil?

SimpleCov.start do
  add_filter '/spec/'
end

require 'flows'

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

RSpec.shared_context 'with helpers' do
  def proc_double(result)
    ->(*) { result }.tap do |proc_obj|
      allow(proc_obj).to receive(:call).and_call_original
      allow(proc_obj).to receive(:===).and_call_original
    end
  end

  def make_proc_double(&block)
    allow(block).to receive(:call).and_call_original
    allow(block).to receive(:===).and_call_original
    block
  end
end

Dir[File.join(__dir__, 'shared', '*.rb')].sort.each { |f| require f }

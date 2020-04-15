require_relative 'output_contract/errors'
require_relative 'output_contract/dsl'
require_relative 'output_contract/wrapper'

module Flows
  module Plugin
    # Allows to make a contract check and transformation for `#call` method execution in any class.
    #
    # Plugin applies a wrapper to a `#call` instance method.
    # This wrapper will do the following:
    #
    # * check that {Result} instance is returned by `#call`
    # * check that returned {Result#status} is expected
    # * check that returned result data conforms {Contract} assigned
    #   to a particular result type and status
    # * applies contract transform to the returned data
    # * returns {Result} with the same status and type,
    #   wraps transformed data inside.
    #
    # Plugin provides DSL to express expected result statuses and assigned contracts.
    # Contracts definition reuses {Contract.make} to execute block and get a contract.
    #
    # * `success_with(status, &block)` - defines contract for a successful result with status `status`.
    # * `failure_with(status, &block)` - defines contract for a failure result with status `status`.
    #
    # @example with one possible output contract
    #     class DoJob
    #       include Flows::Result::Helpers
    #       include Flows::Plugin::OutputContract
    #
    #       success_with :ok do
    #         Integer
    #       end
    #
    #       def call(a, b)
    #         ok_data(a + b)
    #       end
    #     end
    #
    #     DoJob.new.call(1, 2).unwrap
    #     # => 3
    #
    #     DoJob.new.call('a', 'b')
    #     # Flows::Contract::Error exception raised
    #
    # @example with multiple contracts
    #     class DoJob
    #       include Flows::Result::Helpers
    #       include Flows::Plugin::OutputContract
    #
    #       success_with :int_sum do
    #         Integer
    #       end
    #
    #       success_with :float_sum do
    #         Float
    #       end
    #
    #       failure_with :err do
    #         hash_of(
    #           key: Symbol,
    #           msg: String
    #         )
    #       end
    #
    #       def call(a, b)
    #         if a.is_a?(Float) || b.is_a?(Float)
    #           ok_data(a + b, status: :float_sum)
    #         elsif a.is_a?(Integer) && b.is_a?(Integer)
    #           ok_data(a + b, status: :int_sum)
    #         else
    #           err(key: :unexpected_type, msg: "Unexpected argument types")
    #         end
    #       end
    #     end
    module OutputContract
      # @api private
      def self.included(mod)
        mod.extend(DSL)
        mod.prepend(Wrapper)
      end
    end
  end
end

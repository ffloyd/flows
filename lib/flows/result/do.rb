module Flows
  class Result
    # Do-notation for Result Objects.
    #
    # This functionality aims to simplify common control flow pattern:
    # when you have to stop execution on a first failure and return this failure.
    # Do Notation inspired by [Do Notation in dry-rb](https://dry-rb.org/gems/dry-monads/1.3/do-notation/)
    # and [Haskell do keyword](https://wiki.haskell.org/Keywords#do).
    #
    # Sometimes you have to write something like this:
    #
    #     class Something
    #       include Flows::Result::Helpers
    #
    #       def perform
    #         user_result = fetch_user
    #         return user_result if user_result.err?
    #
    #         data_result = fetch_data
    #         return data_result if data_result.err?
    #
    #         calculation_result = calculation(user_result.unwrap[:user], data_result.unwrap)
    #         return calculation_result if user_result.err?
    #
    #         ok(data: calculation_result.unwrap[:some_field])
    #       end
    #
    #       private
    #
    #       def fetch_user
    #         # returns Ok or Err
    #       end
    #
    #       def fetch_data
    #         # returns Ok or Err
    #       end
    #
    #       def calculation(_user, _data)
    #         # returns Ok or Err
    #       end
    #     end
    #
    # The main idea of the code above is to stop method execution and
    # return failed Result Object if one of the sub-operations is failed.
    # At the moment of failure.
    #
    # By using Do Notation feature you may rewrite it like this:
    #
    #     class SomethingWithDoNotation
    #       include Flows::Result::Helpers
    #       extend Flows::Result::Do # enable Do Notation
    #
    #       do_notation(:perform) # changes behaviour of `yield` in this method
    #       def perform
    #         user = yield(fetch_user)[:user] # yield here returns array of one element
    #         data = yield fetch_data # yield here returns a Hash
    #
    #         ok(
    #           data: yield(calculation(user, data))[:some_field]
    #         )
    #       end
    #
    #       # private method definitions
    #     end
    #
    # `do_notation(:perform)` makes some wrapping here and allows you to use `yield`
    # inside the `perform` method in a non standard way:
    # to unpack results or instantly leave a method if a failed result was provided.
    #
    # ## How to use it
    #
    # First of all, you have to include `Flows::Result::Do` mixin into your class or module.
    # It adds `do_notation` class method.
    # `do_notation` accepts method name as an argument and changes behaviour of `yield` inside this method.
    # By the way, when you are using `do_notation` you cannot pass a block to modified method anymore.
    #
    #     class MyClass
    #       extend Flows::Result::Do
    #
    #       do_notation(:my_method_1)
    #       def my_method_1
    #         # some code
    #       end
    #
    #       do_notation(:my_method_2)
    #       def my_method_2
    #         # some code
    #       end
    #     end
    #
    # `yield` in such methods is working by the following rules:
    #
    #     ok_result = Flows::Result::Ok.new(a: 1, b: 2)
    #     err_result = Flows::Result::Err.new(x: 1, y: 2)
    #
    #     # the following three lines are equivalent
    #     yield(ok_result)
    #     ok_result.unwrap
    #     { a: 1, b: 2 }
    #
    #     # the following three lines are equivalent
    #     yield(:a, :b, ok_result)
    #     ok_result.unwrap.values_at(:a, :b)
    #     [1, 2]
    #
    #     # the following three lines are equivalent
    #     return err_result
    #     yield(err_result)
    #     yield(:x, :y, err_result)
    #
    # As you may see, `yield` has two forms of usage:
    #
    # * `yield(result_value)` - returns unwrapped data Hash for successful results or,
    #   in case of failed result, stops method execution and returns failed `result_value` as a method result.
    # * `yield(*keys, result_value)` - returns unwrapped data under provided keys as Array for successful results or,
    #   in case of failed result, stops method execution and returns failed `result_value` as a method result.
    #
    # ## How it works
    #
    # Under the hood `Flows::Result::Do` creates a module and prepends it to your class or module.
    # Invoking `do_notation(:method_name)` adds special wrapper method to the prepended module.
    # So, when you perform call to `YourClassOrModule#method_name` - you're executing wrapper in
    # the prepended module.
    module Do
      MOD_VAR_NAME = :@flows_result_module_for_do

      # Utility functions for Flows::Result::Do.
      #
      # Isolated location prevents polluting user classes with unnecessary methods.
      #
      # @api private
      module Utils
        class << self
          def fetch_and_prepend_module(mod)
            module_for_do = mod.instance_variable_get(MOD_VAR_NAME)
            mod.prepend(module_for_do)
            module_for_do
          end

          # `:reek:TooManyStatements:` - allowed because we have no choice here.
          #
          # `:reek:NestedIterators` - allowed here because here are no iterators.
          def define_wrapper(mod, method_name) # rubocop:disable Metrics/MethodLength
            mod.define_method(method_name) do |*args|
              super(*args) do |*fields, result|
                case result
                when Flows::Result::Ok
                  data = result.unwrap
                  fields.any? ? data.values_at(*fields) : data
                when Flows::Result::Err then return result
                else raise "Unexpected result: #{result.inspect}. Should be a Flows::Result"
                end
              end
            end
          end
        end
      end

      # @api private
      def self.extended(mod)
        ::Flows::Ext::InheritableSingletonVars::IsolationStrategy.call(
          mod,
          MOD_VAR_NAME => -> { Module.new }
        )
      end

      def do_notation(method_name)
        prepended_mod = Utils.fetch_and_prepend_module(self)

        Utils.define_wrapper(prepended_mod, method_name)
      end
    end
  end
end

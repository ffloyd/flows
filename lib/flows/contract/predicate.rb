module Flows
  class Contract
    # Makes a contract from 1-argument lambda.
    #
    # Such lambdas works like [predicates](https://en.wikipedia.org/wiki/Predicate_(mathematical_logic)).
    #
    # @example
    #     positive_check = Flows::Contract::Predicate.new 'must be a positive integer' do |x|
    #       x.is_a?(Integer) && x > 0
    #     end
    #
    #     positive_check === 10
    #     # => true
    #
    #     positive_check === -100
    #     # => false
    class Predicate < Contract
      # @param error_message error message if check fails
      # @yield [object] lambda to wrap into a contract
      # @yieldreturn [Boolean] lambda should return a boolean
      def initialize(error_message, &block)
        @error_message = error_message
        @block = block
      end

      # @see Contract#check!
      def check!(other)
        raise Error.new(other, @error_message) unless @block === other

        true
      end
    end
  end
end

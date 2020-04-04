module Flows
  class Type
    # Type checker for wrapping block checker with error message.
    #
    # @example
    #     positive_check = Flows::Type::Predicate.new 'must be positive' do |x|
    #       x > 0
    #     end
    #
    #     positive_check === 10
    #     # => true
    #
    #     positive_check === -100
    #     # => false
    class Predicate < Type
      def initialize(error_message, &block)
        @error_message = error_message
        @block = block
      end

      def check!(other)
        raise Error.new(other, @error_message) unless @block === other

        true
      end
    end
  end
end

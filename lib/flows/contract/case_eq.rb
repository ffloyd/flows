module Flows
  class Contract
    # Makes a contract from provided object's case equality check.
    #
    # @example String contract
    #     string_check = Flows::Contract::CaseEq.new(String)
    #
    #     string_check.check(111)
    #     # => Flows::Result::Err.new('must match `String`')
    #
    #     string_check === 'sdfdsfsd'
    #     # => true
    #
    # @example Integer contract with custom error message
    #     int_check = Flows::Contract::CaseEq.new(Integer, 'must be an integer')
    #
    #     int_check.check('111')
    #     # => Flows::Result::Err.new('must be an integer')
    #
    #     string_check === 'sdfdsfsd'
    #     # => true
    class CaseEq < Contract
      # @param object [#===] object with case equality
      # @param error_message [String] you may override default error message
      def initialize(object, error_message = nil)
        @object = object
        @error_message = error_message
      end

      # @see Contract#check!
      def check!(other)
        unless @object === other
          value_error =
            @error_message ||
            "must match `#{@object.inspect}`, but has class `#{other.class.inspect}` and value `#{other.inspect}`"
          raise Error.new(other, value_error)
        end

        true
      end
    end
  end
end

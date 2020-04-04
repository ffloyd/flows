module Flows
  class Type
    # Type checker for wrapping standard case equality with error message.
    #
    # @example Adding default error message to a String check
    #     string_check = Flows::Type::Ruby.new(String)
    #
    #     string_check.check(111)
    #     # => Flows::Result::Err.new('must match `String`')
    #
    #     string_check === 'sdfdsfsd'
    #     # => true
    class Ruby < Type
      # @param object [#===] object with case equality
      # @param error_message [String] you may override error message
      def initialize(object, error_message = nil)
        @object = object
        @error_message = error_message
      end

      def check!(other)
        unless @object === other
          value_error = @error_message || "must match `#{@object.inspect}`"
          raise Error.new(other, value_error)
        end

        true
      end
    end
  end
end

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

      private

      def do_check(other)
        if @object === other
          true
        else
          @error_message || "must match `#{@object.inspect}`"
        end
      end
    end
  end
end

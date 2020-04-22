module Flows
  class SharedContextPipeline
    EMPTY_HASH = {}.freeze
    EMPTY_OK = Flows::Result::Ok.new({}.freeze).freeze
    EMPTY_ERR = Flows::Result::Err.new({}.freeze).freeze

    # @api private
    class MutationStep < Step
      NODE_PREPROCESSOR = lambda do |_input, context, node_meta|
        context[:class].before_each_callbacks.each do |callback|
          callback.call(context[:class], node_meta[:name], context[:data], context[:meta])
        end

        [[context[:data]], EMPTY_HASH]
      end

      NODE_POSTPROCESSOR = lambda do |output, context, node_meta|
        case output
        when Flows::Result then output
        else output ? EMPTY_OK : EMPTY_ERR
        end.tap do |result|
          context[:class].after_each_callbacks.each do |callback|
            callback.call(context[:class], node_meta[:name], result, context[:data], context[:meta])
          end
        end
      end
    end
  end
end

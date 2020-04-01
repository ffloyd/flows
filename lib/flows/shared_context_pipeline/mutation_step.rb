module Flows
  class SharedContextPipeline
    EMPTY_HASH = {}.freeze
    EMPTY_OK = Flows::Result::Ok.new(nil).freeze
    EMPTY_ERR = Flows::Result::Err.new(nil).freeze

    # @api private
    class MutationStep < Step
      NODE_PREPROCESSOR = lambda do |_input, context, meta|
        context[:last_step] = meta[:name]

        context[:class].before_each_callbacks.each do |callback|
          callback.call(context[:class], meta[:name], context[:data])
        end

        [[context[:data]], EMPTY_HASH]
      end

      NODE_POSTPROCESSOR = lambda do |output, context, meta|
        case output
        when Flows::Result then output
        else output ? EMPTY_OK : EMPTY_ERR
        end.tap do |result|
          context[:class].after_each_callbacks.each do |callback|
            callback.call(context[:class], meta[:name], context[:data], result)
          end
        end
      end
    end
  end
end

module Flows
  class SharedContextPipeline
    EMPTY_HASH = {}.freeze
    EMPTY_OK = Flows::Result::Ok.new(nil).freeze
    EMPTY_ERR = Flows::Result::Ok.new(nil).freeze

    # @api private
    class MutationStep < Step
      NODE_PREPROCESSOR = lambda do |_input, context, meta|
        context[:last_step] = meta[:name]

        [[context[:data]], EMPTY_HASH]
      end

      NODE_POSTPROCESSOR = lambda do |output, _context, _meta|
        case output
        when Flows::Result then output
        else output ? EMPTY_OK : EMPTY_ERR
        end
      end
    end
  end
end

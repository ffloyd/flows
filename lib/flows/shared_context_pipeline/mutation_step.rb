module Flows
  class SharedContextPipeline
    EMPTY_HASH = {}.freeze

    # @api private
    class MutationStep < Step
      NODE_PREPROCESSOR = lambda do |_input, context, meta|
        context[:last_step] = meta[:name]

        [[context[:data]], EMPTY_HASH]
      end

      NODE_POSTPROCESSOR = lambda do |output, _context, _meta|
        case output
        when Flows::Result then output
        else output ? Flows::Result::Ok.new(nil) : Flows::Result::Err.new(nil)
        end
      end
    end
  end
end

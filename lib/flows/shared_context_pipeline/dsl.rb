require_relative 'dsl/tracks'
require_relative 'dsl/callbacks'

module Flows
  class SharedContextPipeline
    # @api private
    module DSL
      include Tracks
      include Callbacks
    end
  end
end

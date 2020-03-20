module Flows
  # Base class for all library's errors.
  class Error < StandardError; end
end

require 'flows/version'

require 'flows/ext'

require 'flows/router'
require 'flows/result_router'

require 'flows/node'
require 'flows/flow'

require 'flows/result'

module Flows
  class Error < StandardError; end
end

require 'flows/version'

require 'flows/router'
require 'flows/result_router'

require 'flows/node'
require 'flows/flow'

require 'flows/result'
require 'flows/railway'
require 'flows/operation'

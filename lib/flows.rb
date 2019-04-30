module Flows
  class Error < StandardError; end
end

require 'flows/version'

require 'flows/router'
require 'flows/node'
require 'flows/flow'

require 'flows/result'
require 'flows/operation'

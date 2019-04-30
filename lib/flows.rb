module Flows
  class Error < StandardError; end
end

require 'flows/version'

require 'flows/router'
require 'flows/node'
require 'flows/flow'

require 'flows/result'
require 'flows/result/success'
require 'flows/result/failure'
require 'flows/result/helpers'

require 'flows/operation'

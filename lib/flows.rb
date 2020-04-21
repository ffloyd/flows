# Namespace for all the classes and modules of the library.
#
# @since 0.4.0
module Flows
  # Base class for all the library's errors.
  #
  # @since 0.4.0
  class Error < StandardError; end
end

require 'flows/version'

require 'flows/util'
require 'flows/plugin'

require 'flows/result'
require 'flows/contract'
require 'flows/flow'

require 'flows/railway'
require 'flows/shared_context_pipeline'

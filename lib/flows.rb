# Namespace for all the classes and modules of the library.
#
# The most important ones are:
#
# * {Flows::Result}
# * {Flows::Railway}
# * TODO: fill this list
#
# @since 0.4.0
module Flows
  # Base class for all the library's errors.
  #
  # @since 0.4.0
  class Error < StandardError; end
end

require 'flows/version'

require 'flows/ext'
require 'flows/result'
require 'flows/flow'

require 'flows/railway'

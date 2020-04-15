module Flows
  module Plugin
    module OutputContract
      # Contains wrappers for initializer and `#call` methods.
      #
      # @api private
      module Wrapper
        def initialize(*args, &block)
          super(*args, &block)
          raise NoContractError if self.class.success_contracts.empty?
        end

        def call(*args, &block)
          result = super(*args, &block)

          contract = Util.contract_for(self.class, result)
          raise StatusError unless contract

          Util.transform_result(contract, result)

          result
        end

        # Helper methods for {Wrapper} are extracted to this
        # module as singleton methods to not pollute user classes.
        #
        # @api private
        module Util
          class << self
            def contract_for(klass, result)
              raise ResultTypeError unless result.is_a?(Flows::Result)

              status = result.status

              if result.ok?
                klass.success_contracts[status]
              else
                klass.failure_contracts[status]
              end
            end

            def transform_result(contract, result)
              data = result.send(:data)

              transformed_result = contract.transform(data)
              raise ContractError if transformed_result.err?

              result.send(:'data=', transformed_result.unwrap)
            end
          end
        end
      end
    end
  end
end

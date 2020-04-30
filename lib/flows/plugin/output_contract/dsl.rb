module Flows
  module Plugin
    module OutputContract
      # DSL for OutputContract plugin.
      module DSL
        # Hash of contracts for successful results.
        attr_reader :success_contracts

        # Hash of contracts for failure results.
        attr_reader :failure_contracts

        # Is contract check and transformation disabled
        attr_reader :skip_output_contract_flag

        SingletonVarsSetup = Flows::Util::InheritableSingletonVars::DupStrategy.make_module(
          '@success_contracts' => {},
          '@failure_contracts' => {},
          '@skip_output_contract_flag' => false
        )

        include SingletonVarsSetup

        # Defines a contract for a successful result with specific status.
        #
        # @param status [Symbol] Corresponding result status.
        # @param contract_block [Proc] This block will be passed to {Contract.make} to get a contract.
        def success_with(status, &contract_block)
          success_contracts[status] = Flows::Contract.make(&contract_block)
        end

        # Defines a contract for a failure result with specific status.
        #
        # @param status [Symbol] Corresponding result status.
        # @param contract_block [Proc] This block will be passed to {Contract.make} to get a contract.
        def failure_with(status, &contract_block)
          failure_contracts[status] = Flows::Contract.make(&contract_block)
        end

        # Disables contract check and transformation for current class and children.
        #
        # @param enabled [Boolean] if true - contracts are disabled
        def skip_output_contract(enable = true)
          @skip_output_contract_flag = enable
        end
      end
    end
  end
end

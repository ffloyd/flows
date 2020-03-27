module Flows
  class SharedContextPipeline
    # @api private
    module DSL
      attr_reader :steps

      Flows::Ext::InheritableSingletonVars::DupStrategy.call(
        self,
        '@steps' => StepList.new
      )

      def step(name, lambda = nil)
        steps.add_step(name: name, lambda: lambda)
      end

      def mut_step(name, lambda = nil)
        steps.add_mutation_step(name: name, lambda: lambda)
      end
    end
  end
end

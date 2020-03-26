module Flows
  class Railway
    # @api private
    module DSL
      attr_reader :steps

      Flows::Ext::InheritableSingletonVars::DupStrategy.call(
        self,
        '@steps' => StepList.new
      )

      def step(name, lambda = nil)
        steps.add(name: name, lambda: lambda)
      end
    end
  end
end

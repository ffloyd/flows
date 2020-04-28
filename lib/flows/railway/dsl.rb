module Flows
  class Railway
    # @api private
    module DSL
      attr_reader :steps

      SingletonVarsSetup = Flows::Util::InheritableSingletonVars::DupStrategy.make_module(
        '@steps' => StepList.new
      )

      include SingletonVarsSetup

      def step(name, lambda = nil)
        steps.add(name: name, lambda: lambda)
      end
    end
  end
end

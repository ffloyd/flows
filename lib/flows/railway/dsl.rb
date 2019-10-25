module Flows
  class Railway
    # DSL methods for Railway
    module DSL
      attr_reader :steps

      def self.extended(mod)
        ::Flows::Ext::InheritableAttrs.dup_strategy(
          mod,
          '@steps' => StepList.new
        )
      end

      include Flows::Result::Helpers

      def step(name, custom_body = nil)
        @steps.add_step(name: name, custom_body: custom_body)
      end
    end
  end
end

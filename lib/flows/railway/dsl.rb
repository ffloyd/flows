module Flows
  class Railway
    # DSL methods for Railway
    module DSL
      attr_reader :steps

      def self.extended(mod)
        mod.instance_variable_set(:@steps, StepList.new)

        mod.class_exec do
          def self.inherited(subclass)
            subclass.instance_variable_set(:@steps, steps.dup)
            super
          end
        end
      end

      include Flows::Result::Helpers

      def step(name, custom_body = nil)
        @steps.add_step(name: name, custom_body: custom_body)
      end
    end
  end
end

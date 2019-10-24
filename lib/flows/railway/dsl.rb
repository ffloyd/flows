module Flows
  class Railway
    # DSL methods for Railway
    module DSL
      attr_reader :steps

      def self.extended(mod, steps = nil)
        steps ||= []

        mod.instance_variable_set(:@steps, steps)

        mod.class_exec do
          def self.inherited(subclass)
            ::Flows::Railway::DSL.extended(subclass, steps.map(&:dup))
            super
          end
        end
      end

      include Flows::Result::Helpers

      def step(name, custom_body = nil)
        @steps << {
          name: name,
          custom_body: custom_body
        }
      end
    end
  end
end

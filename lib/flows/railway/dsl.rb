module Flows
  module Railway
    # DSL methoda for Railway
    module DSL
      attr_reader :steps

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

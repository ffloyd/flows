module Flows
  module Operation
    class Builder
      # Router builder
      module BuildRouter
        class << self
          def call(custom_routes, next_step, step_names)
            if custom_routes
              custom_router(custom_routes, next_step, step_names)
            else
              Flows::ResultRouter.new(next_step, :term)
            end
          end

          private

          def custom_router(custom_routes, next_step, step_names)
            check_custom_routes(custom_routes, step_names)

            custom_routes[Flows::Result::Ok] ||= next_step
            custom_routes[Flows::Result::Err] ||= :term

            Flows::Router.new(custom_routes)
          end

          def check_custom_routes(custom_routes, step_names)
            custom_routes.values.each do |target|
              next if step_names.include?(target) || target == :term

              raise(::Flows::Operation::NoStepDefinedError, target)
            end
          end
        end
      end
    end
  end
end

module Flows
  module Plugin
    module Profiler
      # @api private
      module Injector
        class << self
          def make_module(method_name)
            Module.new.tap do |mod|
              add_included(mod, method_name)
              add_extended(mod, method_name)
            end
          end

          private

          def add_included(mod, method_name)
            mod.define_method(:included) do |target|
              raise 'must be included into class' unless target.is_a?(Class)

              target.prepend Wrapper.make_module(target, :instance, method_name)
            end
          end

          def add_extended(mod, method_name)
            mod.define_method(:extended) do |target|
              raise 'must be extended into class' unless target.is_a?(Class)

              target.singleton_class.prepend(Wrapper.make_module(target, :singleton, method_name))
            end
          end
        end
      end
    end
  end
end

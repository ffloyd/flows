module Flows
  module Util
    # In the situation when a module is included into another module and only afterwards included into class,
    # allows to force particular module to be prepended to a class only.
    #
    # When you write some module to abstract out some behaviour you may
    # need a way to expand initializer behaviour of a target class.
    # You can prepend a module with an initializer wrapper inside `.included(mod)`
    # or `.extended(mod)` callbacks. But it will not work if you include your module into module
    # and only after to a class. It's one of the cases when `PrependToClass` can help you.
    #
    # Let's show it on example: we need a module which expands initializer to accept `:data`
    # keyword argument and sets its value:
    #
    #     class MyClass
    #       prepend HasData
    #
    #       attr_reader :greeting
    #
    #       def initialize
    #         @greeting = 'Hello'
    #       end
    #     end
    #
    #     module HasData
    #       attr_reader :data
    #
    #       def initialize(*args, **kwargs, &block)
    #         @data = kwargs[:data]
    #
    #         filtered_kwargs = kwargs.reject { |k, _| k == :data }
    #
    #         if filtered_kwargs.empty? # https://bugs.ruby-lang.org/issues/14415
    #           super(*args, &block)
    #         else
    #           super(*args, **filtered_kwargs, &block)
    #         end
    #       end
    #
    #       def big_data
    #         data.upcase
    #       end
    #     end
    #
    #     x = MyClass.new(data: 'aaa')
    #
    #     x.greeting
    #     # => 'Hello'
    #
    #     x.data
    #     # => 'aaa'
    #
    #     x.big_data
    #     # => 'aaa'
    #
    # This implementation works, but has a problem:
    #
    #     class AnotherClass
    #       include Stuff
    #
    #       attr_reader :greeting
    #
    #       def initialize
    #         @greeting = 'Hello'
    #       end
    #     end
    #
    #     module Stuff
    #       prepend HasData
    #     end
    #
    #     x = AnotherClass.new(data: 'aaa')
    #     # ArgumentError: wrong number of arguments (given 1, expected 0)
    #
    # This happens because `prepend` prepends our patch to `Stuff` module, not class.
    # {PrependToClass} solves this problem:
    #
    #     module HasData
    #       attr_reader :data
    #
    #       module InitializePatch
    #         def initialize(*args, **kwargs, &block)
    #           @data = kwargs[:data]
    #
    #           filtered_kwargs = kwargs.reject { |k, _| k == :data }
    #
    #           if filtered_kwargs.empty? # https://bugs.ruby-lang.org/issues/14415
    #             super(*args, &block)
    #           else
    #             super(*args, **filtered_kwargs, &block)
    #           end
    #         end
    #       end
    #
    #       Flows::Util::PrependToClass.call(self, InitializePatch)
    #     end
    #
    #     module Stuff
    #       include HasData
    #     end
    #
    #     class MyClass
    #       include Stuff
    #
    #       attr_reader :greeting
    #
    #       def initialize
    #         @greeting = 'Hello'
    #       end
    #     end
    #
    #     x = MyClass.new(data: 'data')
    #
    #     x.data
    #     # => 'data'
    module PrependToClass
      class << self
        # When `mod` is included into class in any way `module_to_prepend`
        # will be prepended to the class.
        #
        # @param mod [Module] host module
        # @param module_to_prepend [Module] module to be prepended to a class
        def call(mod, module_to_prepend)
          mod.singleton_class.prepend injector(module_to_prepend)
        end

        private

        def injector(module_to_prepend)
          Module.new.tap do |injector|
            injector.define_method(:included) do |target_mod|
              if target_mod.class == Class
                target_mod.prepend(module_to_prepend)
              else # Module
                target_mod.singleton_class.prepend injector
              end

              super(target_mod)
            end
          end
        end
      end
    end
  end
end

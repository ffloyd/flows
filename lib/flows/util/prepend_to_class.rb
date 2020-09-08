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
    #       InitializePatch = Flows::Util::PrependToClass.make_module do
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
    #       include InitializePatch
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
    #
    #     x.greeting
    #     # => 'hello'
    #
    # @note this solution is designed to patch `include` behaviour and
    #   has no effect on `extend`.
    module PrependToClass
      class << self
        # Allows to prepend some module to class when
        # host module included into class.
        #
        # Under the hood two modules are created:
        #
        # * "to prepend" module made from provided block
        # * "container" module which will be returned by this method
        #
        # When you include "container" module into your module `Mod`
        # you're enabling the following behaviour:
        #
        # * when `Mod` included into class - "to prepend" module will be prepended to class
        # * when `Mod` is included into some module `Mod2` - `Mod2` also will
        #   prepend "to prepend" module when included into class.
        # * you can include `Mod` into `Mod2`, then include `Mod2` into `Mod3` -
        #   desribed behavior works for include chain of any length.
        #
        # Each `include` generates a new prepend. Be careful about this when including
        # generated module several times in the inheritance chain.
        #
        # @yield body for module which will be prepended
        # @return [Module] module to be included or extended into your module
        def make_module(&module_body)
          Module.new.tap do |mod|
            to_prepend_mod = Module.new(&module_body)
            mod.const_set(:ToPrepend, to_prepend_mod)

            set_injector_mod(mod, to_prepend_mod)
          end
        end

        private

        def set_injector_mod(mod, module_to_prepend)
          injector = make_injector_mod(module_to_prepend)

          mod.const_set(:Injector, injector)
          mod.singleton_class.prepend(injector)
        end

        def make_injector_mod(module_to_prepend)
          Module.new.tap do |injector|
            injector.define_method(:included) do |target_mod|
              if target_mod.class == Class
                target_mod.prepend(module_to_prepend)
              else # Module
                target_mod.singleton_class.prepend injector
              end

              super(target_mod)
            end

            injector.define_method(:extended) do |target_mod|
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

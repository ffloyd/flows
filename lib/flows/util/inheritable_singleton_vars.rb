module Flows
  module Util
    # Namespace for utility classes which allows you to define specific behaviour for
    # [singleton variables](https://medium.com/@leo_hetsch/demystifying-singleton-classes-in-ruby-caf3fa4c9d91)
    # in the context of inheritance.
    #
    # When you're writing some abstraction in Ruby one of the ways is to provide some base class and
    # allow child classes to configure behaviour through class-level DSL. Something like that:
    #
    #     class UserModel < BaseModel
    #       field :name
    #       field :username
    #     end
    #
    # The first problem here is where to store configuration values?
    # In the most cases of such DSL it's singleton variables.
    #
    # But what will happen if we do something like this:
    #
    #     class AdminModel < UserModel
    #       field :pgp_key
    #     end
    #
    # Which fields are defined for admin? `:name`, `:username` and `:pgp_key`?
    # Or `:pgp_key` only? Both options are possible and can be implemented.
    # But working with singleton variables is confusing and related code is confusing also.
    # So, it's better to implement set of utility modules to define expected behaviour
    # in a human-friendly format.
    #
    # The second problem is default values for singleton variables.
    # In case of instance variables everything is simple:
    # you have a constructor (`#initializer`) and it's the right place to set instance variables defaults.
    # In case of singleton variables you can do it in `.extended` or `.included` callbacks.
    # But this callback will not be executed on child classes. So, we have to add `.inherited` callback to the mix.
    # Confusing? Yes. So, it's better to not think about it each time and
    # use some helpers to explicitly define behaviour.
    #
    # Modules under this namespace provide helpers for defining defaults and inheritance strategy for your
    # singleton variables.
    #
    # Each strategy here is using following way of injecting into yours abstract classes:
    #
    #     class BaseSomething
    #       SingletonVarsSetup = Flows::Util::InheritableSingletonVars::SomeStrategy.make_module(
    #         **options_here
    #       )
    #
    #       include SingeltonVarsSetup # extend also will work
    #     end
    #
    # In case of extensions and mixins:
    #
    #     module MyExtension
    #       SingletonVarsSetup = Flows::Util::InheritableSingletonVars::SomeStrategy.make_module(
    #         **options_here
    #       )
    #
    #       include SingeltonVarsSetup # extend also will work
    #     end
    #
    #     class SomethingA
    #       extend MyExtension
    #     end
    #
    #     module MyMixin
    #       SingletonVarsSetup = Flows::Util::InheritableSingletonVars::SomeStrategy.make_module(
    #         **options_here
    #       )
    #
    #       include SingeltonVarsSetup # extend also will work
    #     end
    #
    #     class SomethingB
    #       include MyMixin
    #     end
    #
    # Moreover, you can use multiple strategies in the same class.
    #
    # @since 0.4.0
    module InheritableSingletonVars
    end
  end
end

require_relative './inheritable_singleton_vars/dup_strategy'
require_relative './inheritable_singleton_vars/isolation_strategy'

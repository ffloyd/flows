require_relative 'railway/errors'
require_relative 'railway/step'
require_relative 'railway/step_list'
require_relative 'railway/dsl'

module Flows
  # Flows::Railway is an implementation of a Railway Programming pattern.
  #
  # You may read about this pattern in the following articles:
  #
  # * [Programming on rails: Railway Oriented Programming](http://sandordargo.com/blog/2017/09/27/railway_oriented_programming).
  #   It's not about Ruby on Rails.
  # * [Railway Oriented Programming: A powerful Functional Programming pattern](https://medium.com/@naveenkumarmuguda/railway-oriented-programming-a-powerful-functional-programming-pattern-ab454e467f31)
  # * [Railway Oriented Programming in Elixir with Pattern Matching on Function Level and Pipelining](https://medium.com/elixirlabs/railway-oriented-programming-in-elixir-with-pattern-matching-on-function-level-and-pipelining-e53972cede98)
  #
  # Let's review a simple task and solve it using {Flows::Railway}:
  #
  # * you have to get a user by ID
  # * get all user's blog posts
  # * and convert it to an array of HTML-strings
  #
  # In such situation, we have to implement three parts of our task and compose it into something we can call,
  # for example, from a Rails controller.
  # Also, the first and third steps may fail (user not found, conversion to HTML failed).
  # And if a step failed - we have to return failure info immediately.
  #
  #     class RenderUserBlogPosts < Flows::Railway
  #       step :fetch_user
  #       step :get_blog_posts
  #       step :convert_to_html
  #
  #       def fetch_user(id:)
  #         user = User.find_by_id(id)
  #         user ? ok(user: user) : err(message: "User #{id} not found")
  #       end
  #
  #       def get_blog_posts(user:)
  #         ok(posts: User.posts)
  #       end
  #
  #       def convert_to_html(posts:)
  #         posts_html = post.map(&:text).map do |text|
  #           html = convert(text)
  #           return err(message: "cannot convert to html: #{text}")
  #         end
  #
  #         ok(posts_html: posts_html)
  #       end
  #
  #       private
  #
  #       # returns String or nil
  #       def convert(text)
  #         # some implementation here
  #       end
  #     end
  #
  #     RenderUserBlogPosts.call(id: 10)
  #     # result object returned
  #
  # Let's describe how it works.
  #
  # First of all you have to inherit your railway from `Flows::Railway`.
  #
  # Then you must define list of your steps using `step` DSL method.
  # Steps will be executed in the given order.
  #
  # The you have to provide step implementations. It should be done by using
  # public methods with the corresponding names.
  # _Please write your step implementations in the step definition order._
  # _It will make your railway easier to read by other engineers._
  #
  # Each step should return {Flows::Result} Object.
  # If Result Object is successful - next step will be called or
  # this object becomes a railway execution result in the case of last step.
  # If Result Object is failure - this object becomes execution result immediately.
  #
  # Place all the helpers methods in the private section of the class.
  #
  # To help with writing methods {Flows::Result::Helpers} is already included.
  #
  # {Railway} is a very simple but not very flexible abstraction.
  # It has a good performance and a small overhead.
  #
  # ## `Flows::Railway` execution rules
  #
  # * steps execution happens from the first to the last step
  # * input arguments (`Railway#call(...)`) becomes the input of the first step
  # * each step should return Result Object (`Flows::Result::Helpers` already included)
  # * if step returns failed result - execution stops and failed Result Object returned from Railway
  # * if step returns successful result - result data becomes arguments of the following step
  # * if the last step returns successful result - it becomes a result of a Railway execution
  #
  # ## Step definitions
  #
  # Two ways of step definition exist. First is by using an instance method:
  #
  #     step :do_something
  #
  #     def do_something(**arguments)
  #       # some implementation
  #       # Result Object as return value
  #     end
  #
  # Second is by using lambda:
  #
  #     step :do_something, ->(**arguments) { ok(some: 'data') }
  #
  # Definition with lambda exists for debugging/testing purposes, it has higher priority than method implementation.
  # _Do not use lambda implementations for your business logic!_
  #
  # __Think about Railway as about small book: you have a "table of contents"
  # in a form of step definitions and actual "chapters" in the same order
  # in a form of public methods. And your private methods becomes something like "appendix".__
  #
  # ## Advanced initialization
  #
  # In a simple case you can just invoke `YourRailway.call(..)`. Under the hood it works like `.new.call(...)`,
  # but `.new` part will be executed ones and memoized ({Flows::Utils::ImplicitInit} included).
  #
  # You can include {Flows::Utils::DependencyInjector} into your Railway and in this case you will
  # need to do `.new(...).call` manually.
  class Railway
    extend ::Flows::Utils::ImplicitInit

    include ::Flows::Result::Helpers
    extend ::Flows::Result::Helpers

    extend DSL

    def initialize
      steps = self.class.steps

      @__flows_railway_flow = Flows::Flow.new(
        start_node: steps.first_step_name,
        node_map: steps.to_node_map(self)
      )
    end

    # Executes Railway with provided keyword arguments, returns Result Object
    #
    # @return [Flows::Result]
    def call(**kwargs)
      context = {}

      @__flows_railway_flow.call(ok(**kwargs), context: context).tap do |result|
        result.meta[:last_step] = context[:last_step]
      end
    end
  end
end

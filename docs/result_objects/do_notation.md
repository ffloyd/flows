# Result Object :: Do Notation

Sometimes you have to write something like this:

```ruby
class Something
  include Flows::Result::Helpers

  # All methods return Result Object

  def do_job
    user_result = fetch_user
    return user_result if user_result.err?

    data_result = fetch_data
    return data_result if data_result.err?

    calculation_result = calculation(user_result.unwrap[:user], data_result.unwrap)
    return calculation_result if user_result.err?

    ok(data: calculation_result.unwrap[:some_field])
  end

  private

  def fetch_user
    result
  end

  def fetch_data
    result
  end

  def calculation(_user, _data)
    result
  end
end
```

The main idea of the code above is to stop method execution and return failed Result Object if one of the sub-operations is failed. At the moment of failure.

By using Do Notation feature you may rewrite it like this:

```ruby
class SomethingWithDoNotation
  include Flows::Result::Helpers
  include Flows::Result::Do # enable Do Notation

  # All methods return Result Object

  do_for(:do_job) # changes behaviour of `yield` in this method
  def do_job
    user, = yield :user, fetch_user # yield here returns array of one element
    data = yield fetch_data # yield here returns a Hash

    ok(data: yield(:some_field, calculation(user, data))[0])
  end

  # private method definitions
end
```

or like this:

```ruby
do_for(:do_job)
def do_job
  user = yield(fetch_user)[:user] # yield here and below returns a Hash
  data = yield fetch_data

  ok(data: yield(calculation(user, data))[:some_field])
end
```

`do_for(:do_job)` makes some simple magic here and allows you to use `yield` inside `do_job` in a non standard way:
to unpack results or instantly leave a method if a failed result provided.

## How to use it

First of all, you have to include `Flows::Result::Do` mixin into your class or module. It adds `do_for` class method.
`do_for` accepts method name as an argument and changes behaviour of `yield` inside this method. By the way, when you are using
`do_for` you cannot pass a block to modified method anymore.

Then `do_for` method should be used to enable Do Notation for certain methods.

```ruby
class MyClass
  include Flows::Result::Do

  do_for(:my_method_1)
  def my_method_1
    # some code
  end

  do_for(:my_method_2)
  def my_method_2
    # some code
  end
end
```

`yield` in such methods starts working by following rules:

```ruby
ok_result = Flows::Result::Ok.new(a: 1, b: 2)
err_result = Flows::Result::Err.new(x: 1, y: 2)

# following three lines are equivalent
yield(ok_result)
ok_result.unwrap
{ a: 1, b: 2 }

# following three lines are equivalent
yield(:a, :b, ok_result)
ok_result.unwrap.values_at(:a, :b)
[1, 2]

# following two lines are equivalent
yield(err_result)
return err_result

# following two lines are equivalent
yield(:x, :y, err_result)
return err_result
```

As you may see, `yield` has two forms of usage:

* `yield(result_value)` - returns unwrapped data Hash for successful results or,
  in case of failed result, stops method execution and returns failed `result_value` as a method result.
* `yield(*keys, result_value)` - returns unwrapped data under provided keys as Array for successful results or,
  in case of failed result, stops method execution and returns failed `result_value` as a method result.

## How it works

Under the hood `Flows::Result::Do` creates a module and prepends it to your class or module.
Invoking of `do_for(:method_name)` adds special wrapper method to the prepended module. So, when you perform call to
`YourClassOrModule#method_name` - you execute wrapper in the prepended module.

Check out source code for implementation details.

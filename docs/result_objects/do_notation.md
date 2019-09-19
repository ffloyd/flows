# Result Object :: Do Notation

Sometimes you have write something like this:

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
    # some code
  end

  def fetch_data
    # some code
  end

  def calculation(user, data)
    # some calculation based on user and data, may be failed
  end
end
```

The main idea of code above is to return failed Result Object if one of sub-operations is failed.

By using Do Notation feature you may rewrite it like this:

```ruby
class SomethingWithDoNotation
  include Flows::Result::Helpers
  include Flows::Result::Do

  # All methods return Result Object

  do_for(:do_job)
  def do_job
    user = yield :user, fetch_user

    data = yield fetch_data

    ok(data: yield(:some_field, calculation(user, data)))
  end

  private

  def fetch_user
    # some code
  end

  def fetch_data
    # some code
  end

  def calculation(user, data)
    # some calculation based on user and data, may be failed
  end
end
```

`do_for(:do_job)` makes some simple magic here and allows you to use `yield` inside `do_job` in a non standard way: to unpack results or instantly leave a method if a failed result provided.

## How to use it

TODO:

## How it works

TODO:

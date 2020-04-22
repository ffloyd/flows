# Flows

[![Build Status](https://github.com/ffloyd/flows/workflows/Test/badge.svg)](https://github.com/ffloyd/flows/actions)
[![codecov](https://codecov.io/gh/ffloyd/flows/branch/master/graph/badge.svg)](https://codecov.io/gh/ffloyd/flows)
[![Gem Version](https://badge.fury.io/rb/flows.svg)](https://badge.fury.io/rb/flows)

Small and fast ruby framework for implementing railway-like operations.
By design it is close to
[Trailblazer::Operation](http://trailblazer.to/gems/operation/2.0/),
[Dry::Transaction](https://dry-rb.org/gems/dry-transaction/) and Rust control
flow style.
Flows has simple and flexible DSL for defining operations and matching results.
Also `flows` is faster than Ruby's alternatives.

`flows` has no production dependencies so it can be used with any framework.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'flows', '~> 0.4'
```

And then execute:

```sh
bundle
```

Or install it yourself as:

```sh
gem install flows
```

## Supported Ruby versions

CI tests against last patch versions every day:

* `MRI 2.5.x`
* `MRI 2.6.x`

`MRI 2.7.x` will be added later, right now (`2.7.1`) this version of MRI Ruby is too
unstable and produce segmentation faults inside RSpec internals.

## Usage & Documentation

* [YARD documentation](https://rubydoc.info/github/ffloyd/flows/master) - this
  link is for master branch. You can also find YARD documentation for any released
  version after `v0.4.0`. This documentation has a lot of examples, describes
  motivation behind each abstraction, but lacks some guides and defined conventions.
* [Guides](https://ffloyd.github.io/flows/#/) - guides, conventions, integration
  and migration notes. Will be done before `v1.0.0` release. Right now is under development.

## Development

`Flows` is designed to be framework for your business logic. It is a big
responsibility. That's why `flows` has near to be sadistic development
conventions and linter setup.

### Anyone can make Flows even better

If you see some typos or unclear things in documentation or code - feel free to open
an issue. Even if you don't have plans to implement a solution - a problem reporting
will help development much. We cannot fix what we don't know.

### [Lefthook](https://github.com/Arkweid/lefthook) as a git hook manager

Installation on MacOS via Homebrew:

```sh
brew install Arkweid/lefthook/lefthook
```

Activation (in the root of the repo):

```sh
lefthook install
```

Run hooks manually:

```sh
lefthook run pre-commit
lefthook run pre-push
```

Please, never turn off the pre-commit and pre-push hooks.

### Rubocop linter

[Rubocop](https://docs.rubocop.org/en/stable/) in this setup is responsible for:

* defining code style (indentation, etc.)
* suggest performance improvements ([rubocop-performance](https://docs.rubocop.org/projects/performance/en/stable/))
* forces all that stuff (with some exceptions) to snippets in Markdown files ([rubocop-md](https://github.com/rubocop-hq/rubocop-md))
* forces unit-testing best practices ([rubocop-rspec](https://docs.rubocop.org/projects/rspec/en/latest/))

Rubocop config for library and RSpec files should be close to standard one only
with minor amount of exceptions.

Code in Markdown snippets and `/bin` folder can ignore more rules. `/bin` folder
contains only development-related scripts and tools so it's ok to ease linter requirements.

Rubocop Metrics (ABC-size, method/class length, etc) must not be eased
globally. Never.

### Reek linter

[Ruby Reek](https://github.com/troessner/reek) is a very aggressive linter that
forces you to do a clean OOP design.

You will be tempted to just shut up this linter many times. But believe me, in 9
of 10 cases it worth to refactor. And after each such refactoring you will
understand OOP design better and better.

### Rest of the linters

* [MDL](https://github.com/markdownlint/markdownlint) - for consistent format of Markdown files
* [forspell](https://github.com/kkuprikov/forspell) - for spellchecking in comments and markdown files
* [inch](http://rrrene.org/inch/) - for documentation coverage suggestions (the
  only optional linter)

### Default Rake task and CI

Default rake task (`bundle exec rake`) executes the following checks:

* Rubocop
* Ruby Reek
* RSpec
* Spellcheck (forspell)
* MarkdownLint (mdl)

CI is also performing default Rake task. So, if you want to reproduce CI error
locally - just run `bundle exec rake`.

Default Rake task is also executed as a pre-push git hook.

### Error reporting

I hope no one will argue that clear errors makes development noticeably faster.
That's why _each_ exception in `flows` should be clear and easy to read.

This cannot be tested automatically: you only can test correctness
automatically, convenience can only be tested manually. That's why when you
introduce any new `raise` you have to:

* make an error message clear and descriptive
* add this error to _errors demo CLI_ (`bin/errors`)
* add this errors to _all the errors demo_ (`bin/all_the_errors`)
* make sure that error is displayed correctly and follows a style of the rest
  of implemented errors

`bin/errors` is done using [GLI](https://davetron5000.github.io/gli/) library,
run `bin/errors -h` to explore possibilities.

### Performance

Ruby is slow. Moreover, Ruby is very slow. Yes, again. In the past time we had
to compare Ruby with Python. Python was faster and that's why people started to
complain about Ruby performance. That was fixed. But is Ruby fast nowadays? No.
Because languages like Clojure, Go, Rust, Elixir appeared and in comparison
with any of these languages Ruby is very very slow.

That's why you **must** be extra careful with performance. Some business
operations can be executed hundreds or even thousands times per request. Each
line of code in your abstraction will slow down such request a bit. That's why
you should think about each line performance.

Also, it's nearly impossible to make zero-cost abstractions in Ruby. The best
thing you can do - to offload calculations to a class loading or initialization
step. Sacrifice some warm-up time to make runtime performance better.

And to compare performance overhead between different `flows` abstractions
and another alternatives a benchmarking CLI was done: `bin/benchmark`.

This CLI is done using GLI, run `bin/benchmark -h` to explore possibilities.

So far, `flows` offers the best performance among alternatives. And this CLI
is made to simplify comparison with alternatives and keep `flows` the fastest solution.

### Documentation

Each public API method or module **must** be properly documented with examples
and motivation behind.

To run documentation server locally run `bin/docserver`.

Respect `@since` YARD documentation tag. When some module, class or method has any
API change - you have to provide correct `@since` tag value to the documentation.

### Documentation Driven Development

When you about to do some work, the following guideline can lead to the best
results:

* first, write needed class and method structure without implementation
* write YARD documentation with motivation and usage examples for each public
  class, method, module.
* write unit tests, check that tests are failing
* write implementation until tests are green

Yes, it's TDD approach with documentation step prepended.

### Unit test

Each public API method or module **must** be properly tested. Internal modules
can be tested indirectly through public API.

Test coverage **must** be higher than 95%.

### Commit naming

You **must** follow [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/).

Allowed prefixes since `v0.4.0`:

* `feat:` - for new features
* `fix:` - for bugfixes
* `perf:` - for performance improvements
* `refactor:` - for refactoring work
* `ci:` - updates for CI configuration
* `docs:` - for documentation update

Sometimes commit can have several responsibilities. As example: when you write
documentation, test and implementation for a feature in the one commit. You can do
extra effort to split and rearrange commits to make it atomic. But does it
really provide significant value if we already have a strong convention for
changelog (see the next section)?

So, when you in such situation use the first applicable prefix in the list:
between `docs` and `refactor` - pick `refactor`.

Also, there is one more special prefix for release commits. Release commit
messages **must** look like: `release: v0.4.0`.

### Changelog

Starting from `v0.4.0` [keep a changelog](https://keepachangelog.com/en/1.0.0/)
guideline must be met.

If you adding something - provide some lines to the unreleased section of the `CHANGELOG.md`.

### Versioning

The project strictly follows [SemVer](https://semver.org/spec/v2.0.0.html).

After `v1.0.0` even smallest backward incompatible change will bump major
version. _No exceptions._

Commit with a version bump should contain _only_ version bump and CHANGELOG.md update.

### GitHub Flow

Since `v0.4.0` this repo strictly follow [GitHub
Flow](https://guides.github.com/introduction/flow/) with some additions:

* branch naming using dash: `improved-contexts`
* use [references to
  issues](https://help.github.com/en/github/managing-your-work-on-github/linking-a-pull-request-to-an-issue#linking-a-pull-request-to-an-issue-using-a-keyword)
  in commit messages and make links to issues in CHANGELOG.md

### Planned features for v1.0.0

* validation framework
* error reporting improvements
* various plugins for SCP (tracing, benchmarking, logging, etc)
* site with guides and conventions

# Flows

[![Build Status](https://github.com/ffloyd/flows/workflows/Build/badge.svg)](https://github.com/ffloyd/flows/actions)
[![codecov](https://codecov.io/gh/ffloyd/flows/branch/master/graph/badge.svg)](https://codecov.io/gh/ffloyd/flows)
[![Gem Version](https://badge.fury.io/rb/flows.svg)](https://badge.fury.io/rb/flows)

**Right now library is under heavy development. Version 0.4.0 will be the first stable API candidate. And version 1.0.0 is coming after.**

Small and fast ruby framework for implementing railway-like operations.
By design it is close to [Trailblazer::Operation](http://trailblazer.to/gems/operation/2.0/) and [Dry::Transaction](https://dry-rb.org/gems/dry-transaction/),
but has simpler and flexible DSL for defining operations and matching results. Also `flows` is faster.

`flows` has no production dependencies so it can be used with any framework.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'flows'
```

And then execute:

```sh
bundle
```

Or install it yourself as:

```sh
gem install flows
```

_Rest of documentation will be here when v0.4.0 be ready._ Stay tuned.

## Readme TODO: list of tasks to accomplish before

* [ ] lefthook usage
* [ ] `bundle exec rake` to check all the things + describe linter setup
* [ ] describe why so many linters
* [ ] `bin/*` scripts usage
* [ ] about mandatory `@since` usage in docs


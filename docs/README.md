# Flows

[![Build Status](https://travis-ci.com/ffloyd/flows.svg?branch=master)](https://travis-ci.com/ffloyd/flows)
[![codecov](https://codecov.io/gh/ffloyd/flows/branch/master/graph/badge.svg)](https://codecov.io/gh/ffloyd/flows)
[![Gem Version](https://badge.fury.io/rb/flows.svg)](https://badge.fury.io/rb/flows)

Small and fast ruby framework for implementing railway-like operations.
By design it is close to [Trailblazer::Operation](http://trailblazer.to/gems/operation/2.0/) and [Dry::Transaction](https://dry-rb.org/gems/dry-transaction/),
but has simpler and flexible DSL for defining operations and matching results. Also `flows` is faster, see [Performance](overview/performance.md).

`flows` has no production dependencies so it can be used with any framework.

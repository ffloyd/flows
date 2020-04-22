# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

Types of changes:

* _Added_ - for new features.
* _Changed_ -  for changes in existing functionality.
* _Deprecated_ - for soon-to-be removed features.
* _Removed_ - for now removed features.
* _Fixed_ -- for any bug fixes.
* _Security_ - in case of vulnerabilities.

## [Unreleased]

### Changed

* `Flows::SharedContextPipeline` callback API, GitHub issue: #6

## [0.4.0] - 2020-04-21

### Added

* `Flows::Contract` - type contracts with specific transformation feature.
* `Flows::Flow` - fast and lightweight logic execution engine, designed for
  internal usage and library writers.
* `Flows::Plugin::DependencyInjector` - simple dependency injection plugin for your classes
* `Flows::Plugin::ImplicitInit` - allows to use `MyClass.call` instead of
  `MyClass.new.call`, an class instance will be created once.
* `Flows::Plugin::OutputContract` - plugin for output type checks and
  transformations for service objects which return `Flows::Result`.
* `Flows::Railway` - stupid simple implementation of the railway pattern.
* `Flows::Result` - general purpose Result Object designed after Rust Result type.
* `Flows::Result::Do` - do-notation for Result Objects.
* `Flows::SharedContextPipeline` - much more flexible adoption of the railway
  pattern for Ruby.
* `Flows::Util::InheritableSingletonVars` - allows to define behavior for
  singleton variables in the context of inheritance.
* `Flows::Util::PrependToClass` - allows to prepend some module to class even if
  target module did not included directly into class.

[unreleased]: https://github.com/ffloyd/flows/compare/v0.4.0...HEAD
[0.4.0]: https://github.com/ffloyd/flows/compare/v0.3.0...v0.4.0

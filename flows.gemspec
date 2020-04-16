lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'flows/version'

Gem::Specification.new do |spec| # rubocop:disable Metrics/BlockLength
  spec.name          = 'flows'
  spec.version       = Flows::VERSION
  spec.authors       = ['Roman Kolesnev']
  spec.email         = ['rvkolesnev@gmail.com']

  spec.summary       = 'Ruby framework for building your Business Logic Layer inside Rails and other frameworks.'
  spec.homepage      = 'https://github.com/ffloyd/flows'
  spec.license       = 'MIT'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  # This library has no production dependencies.
  # So, it will not block you from updating any dependencies in your project.
  # So, don't add production dependencies.

  # things that should be part of a standard library
  spec.add_development_dependency 'bundler', '~> 2.0'
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'rspec', '~> 3.0'

  # Documentation is the key!
  spec.add_development_dependency 'yard'

  # linters to make code and documentation awesome
  spec.add_development_dependency 'forspell', '~> 0.0.8'
  spec.add_development_dependency 'inch'
  spec.add_development_dependency 'mdl'
  spec.add_development_dependency 'reek'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'rubocop-md'
  spec.add_development_dependency 'rubocop-performance'
  spec.add_development_dependency 'rubocop-rspec'

  # let's make dubugging confortable
  spec.add_development_dependency 'awesome_print'
  spec.add_development_dependency 'pry'

  # 100% coverage does not mean that you cover everything,
  # but 50% coverage means that you haven't covered half of the project.
  spec.add_development_dependency 'codecov'
  spec.add_development_dependency 'simplecov'

  # benchmarking tools
  spec.add_development_dependency 'benchmark-ips'
  spec.add_development_dependency 'kalibera'
  spec.add_development_dependency 'ruby-prof'
  spec.add_development_dependency 'stackprof'

  # make benchmark scripts a convinient CLI tool
  spec.add_development_dependency 'gli'
  spec.add_development_dependency 'rainbow'
  spec.add_development_dependency 'warning' # to suppress some unhandable Ruby warnings during CLI execution

  # alternatives for comparison in benchmarking
  spec.add_development_dependency 'dry-monads', '~> 1.3'
  spec.add_development_dependency 'dry-transaction'
  spec.add_development_dependency 'trailblazer-operation'
end

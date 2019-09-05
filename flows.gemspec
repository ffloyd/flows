lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'flows/version'

Gem::Specification.new do |spec|
  spec.name          = 'flows'
  spec.version       = Flows::VERSION
  spec.authors       = ['Roman Kolesnev']
  spec.email         = ['rvkolesnev@gmail.com']

  spec.summary       = 'Ruby framework for building FSM-like data flows.'
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

  spec.add_development_dependency 'bundler', '~> 2.0'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'

  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'rubocop-performance'
  spec.add_development_dependency 'rubocop-rspec'

  spec.add_development_dependency 'pry'

  spec.add_development_dependency 'codecov'
  spec.add_development_dependency 'simplecov'

  # benchmarking tools
  spec.add_development_dependency 'benchmark-ips'
  spec.add_development_dependency 'ruby-prof'
  spec.add_development_dependency 'stackprof'

  # alternatives for comparison in benchmarking
  spec.add_development_dependency 'dry-transaction'
  spec.add_development_dependency 'trailblazer-operation'
end

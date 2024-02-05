lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'flows/version'

Gem::Specification.new do |spec|
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

  spec.required_ruby_version = '>= 3.0'

  # This library has no production dependencies.
  # So, it will not block you from updating any dependencies in your project.
  # So, don't add production dependencies.

  spec.metadata['rubygems_mfa_required'] = 'true'
end

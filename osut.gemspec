lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "osut/version"

Gem::Specification.new do |spec|
  spec.name          = "osut"
  spec.version       = OSut::VERSION
  spec.platform      = Gem::Platform::RUBY
  spec.authors       = ["Denis Bourgeois"]
  spec.email         = ["denis@rd2.ca"]

  spec.summary       = "OpenStudio UTilities"
  spec.description   = "General purpose utilities for OpenStudio SDK-based apps"
  spec.homepage      = "https://github.com/rd2/osut"
  spec.license       = "BSD-3-Clause"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the
  # "allowed_push_host" to allow pushing to a single host or delete this section
  # to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["homepage_uri"] = spec.homepage
    spec.metadata["source_code_uri"] = "#{spec.homepage}/tree/v#{spec.version}"
    spec.metadata["changelog_uri"] = "#{spec.homepage}/issues"
  else
    raise "RubyGems >= 2.0 is required to protect against public gem pushes."
  end

  # Specify which files should be added to the gem when it is released.
  # "git ls-files -z" loads files in the RubyGem that have been added into git.
  spec.files         = "git ls-files -z".split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end

  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  if /^2.5/.match(RUBY_VERSION)
    spec.required_ruby_version = "~> 2.5.0"

    spec.add_development_dependency "bundler",        "~> 2.1"
    spec.add_development_dependency "rake",           "~> 13.0"
    spec.add_development_dependency "rspec",          "~> 3.9"
    spec.add_development_dependency "yard",           "~> 0.9"
  else
    spec.required_ruby_version = "~> 2.7.0"

    spec.add_development_dependency "bundler",        "~> 2.1"
    spec.add_development_dependency "rake",           "~> 13.0"
    spec.add_development_dependency "rspec",          "~> 3.9"
    spec.add_development_dependency "yard",           "~> 0.9"
  end
end

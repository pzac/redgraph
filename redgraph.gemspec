# frozen_string_literal: true

require_relative "lib/redgraph/version"

Gem::Specification.new do |spec|
  spec.name          = "redgraph"
  spec.version       = Redgraph::VERSION
  spec.authors       = ["Paolo Zaccagnini"]
  spec.email         = ["hi@pzac.net"]

  spec.summary       = "A simple RedisGraph client"
  spec.homepage      = "https://github.com/pzac/redgraph"
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.4.0")

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/CHANGELOG.md"

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0")
  end
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"
end

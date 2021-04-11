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
  spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/master/CHANGELOG.md"

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0")
  end
  spec.require_paths = ["lib"]

  spec.add_dependency "redis", "~> 4"
end

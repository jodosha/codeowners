# frozen_string_literal: true

require_relative "lib/codeowners/version"

Gem::Specification.new do |spec|
  spec.name          = "codeowners"
  spec.version       = Codeowners::VERSION
  spec.authors       = ["Luca Guidi"]
  spec.email         = ["me@lucaguidi.com"]

  spec.summary       = "GitHub Codeowners check and guess"
  spec.description   = "Check GitHub Codeowners and guess which team should be assigned to a file"
  spec.homepage      = "https://lucaguidi.com"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.5.0")

  spec.metadata["allowed_push_host"] = "https://rubygems.org"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/jodosha/codeowners"
  spec.metadata["changelog_uri"] = "https://github.com/jodosha/codeowners/blob/master/CHANGELOG.md"

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "dry-cli", "~> 0.6"
  spec.add_runtime_dependency "excon", "~> 0.75"
  spec.add_development_dependency "rubocop"
  spec.add_development_dependency "byebug"
end

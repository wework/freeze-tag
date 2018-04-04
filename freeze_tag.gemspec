
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "freeze_tag/version"

Gem::Specification.new do |spec|
  spec.name          = "freeze_tag"
  spec.version       = FreezeTag::VERSION
  spec.authors       = ["Paul Franzen"]
  spec.email         = ["paul@wework.com"]

  spec.summary       = %q{A stateless tagging library}
  spec.homepage      = "https://wework.com"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "rails", ">= 4.2"

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.6"
  spec.add_development_dependency "rspec-rails", "~> 3.6"
  spec.add_development_dependency "byebug", "~> 9.0"
  spec.add_development_dependency "pry-byebug", "~> 3.4"
  spec.add_development_dependency "sqlite3", "~> 1.3"
  spec.add_development_dependency "database_cleaner", "~> 1.5"
  spec.add_development_dependency 'appraisal'
  spec.add_development_dependency 'webmock'
end

# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = "sequel-mysql_json"
  spec.version       = "0.1.0"
  spec.authors       = ["Damián Silvani"]
  spec.email         = ["munshkr@gmail.com"]

  spec.summary       = %q{Sequel extension and plugin that adds better support for MySQL JSON columns.}
  spec.description   = %q{
    Sequel extension and plugin that adds better support for MySQL JSON columns.

    `mysql_json_op` extension adds support to Sequel's DSL to make it easier to
    call MySQL JSON function and operators (added first on MySQL 5.7.8).

    `mysql_json` plugin detects MySQL json columns on models and adds column
    accessor that deserializes JSON values automatically (using Sequel's
    built-in Serialization plugin).
  }
  spec.homepage      = "https://github.com/munshkr/sequel-mysql_json"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.12"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest", "~> 5.0"

  spec.add_dependency 'sequel', '>= 4'
end

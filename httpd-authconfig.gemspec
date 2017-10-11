lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

# Declare Gem's Version
require "httpd_authconfig/version"

# Declare Dependencies
Gem::Specification.new do |s|
  s.name          = "httpd-authconfig"
  s.version       = HttpdAuthConfig::VERSION
  s.authors       = ["Httpd Auth Config Developers"]
  s.homepage      = "https://github.com/abellotti/httpd-authconfig.git"
  s.summary       = "The Httpd AuthConfig"
  s.description   = "The Httpd AuthConfig"
  s.licenses      = ["Apache-2.0"]

  s.files         = Dir["{lib}/**,*", "LICENSE.txt", "README.md"]
  s.require_paths = ["lib"]

  s.add_development_dependency "rspec",    "~> 3.0"

  s.add_dependency "activesupport",        ">=5.0"
  s.add_dependency "trollop",              "~> 2.1"
  s.add_dependency "awesome_spawn",        "~> 1.4"
  s.add_dependency "more_core_extensions", "~> 3.4"
end

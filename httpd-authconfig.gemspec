# lib = $:.push File.expand_path("../lib", __FILE__)
# $LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
$:.push File.expand_path("../lib", __FILE__)

# Declare Gem's Version
require "httpd/authconfig/version"

# Declare Dependencies
Gem::Specification.new do |s|
  s.name          = "httpd-authconfig"
  s.version       = Httpd::AuthConfig::VERSION
  s.authors       = ["ManageIQ Developers"]
  s.homepage      = "https://github.com/abellotti/httpd-authconfig.git"
  s.summary       = "The Httpd AuthConfig"
  s.description   = "The Httpd AuthConfig"
  s.licenses      = ["Apache-2.0"]

  s.files         = Dir["{app,lib}/**/*", "LICENSE.txt", "Rakefile", "README.md"]
  # s.require_paths = ["lib"]

  s.add_dependency "awesome_spawn",     "~> 1.4"
  s.add_dependency "trollop",           "~> 2.1"
end

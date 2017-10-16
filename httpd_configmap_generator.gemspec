lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

# Declare Gem's Version
require "httpd_configmap_generator/version"

# Declare Dependencies
Gem::Specification.new do |s|
  s.name          = "httpd_configmap_generator"
  s.version       = HttpdConfigmapGenerator::VERSION
  s.authors       = ["Httpd Auth Config Developers"]
  s.homepage      = "https://github.com/abellotti/httpd_configmap_generator"
  s.summary       = "The Httpd Configmap Generator"
  s.description   = "The Httpd Configmap Generator"
  s.licenses      = ["Apache-2.0"]

  s.files         = Dir["{lib}/**,*", "LICENSE.txt", "README.md"]
  s.require_paths = ["lib"]

  s.add_development_dependency "rspec",    "~> 3.0"

  s.add_dependency "activesupport",        ">=5.0"
  s.add_dependency "trollop",              "~> 2.1"
  s.add_dependency "awesome_spawn",        "~> 1.4"
  s.add_dependency "more_core_extensions", "~> 3.4"
end

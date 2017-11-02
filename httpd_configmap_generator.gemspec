lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

# Declare Gem's Version
require "httpd_configmap_generator/version"

# Declare Dependencies
Gem::Specification.new do |s|
  s.name          = "httpd_configmap_generator"
  s.version       = HttpdConfigmapGenerator::VERSION
  s.authors       = ["Httpd Auth Config Developers"]
  s.homepage      = "https://github.com/ManageIQ/httpd_configmap_generator"
  s.summary       = "The Httpd Configmap Generator"
  s.description   = "The Httpd Configmap Generator"
  s.licenses      = ["Apache-2.0"]

  if Dir.exist?(File.join(__dir__, ".git"))
    s.files = `git ls-files -z`.split("\x0").reject do |f|
      f.match(%r{^(test|spec|features)/})
    end
  end
  s.bindir        = "bin"
  s.executables   = s.files.grep(%r{^bin/}) { |f| File.basename(f) } - %w(console setup)
  s.require_paths = ["lib"]

  s.add_development_dependency "codeclimate-test-reporter", "~> 1.0.0"
  s.add_development_dependency "rspec",    "~> 3.0"
  s.add_development_dependency "rake"
  s.add_development_dependency "simplecov"

  s.add_dependency "activesupport",        ">=5.0"
  s.add_dependency "awesome_spawn",        "~> 1.4"
  s.add_dependency "iniparse",             "~> 1.4"
  s.add_dependency "more_core_extensions", "~> 3.4"
  s.add_dependency "trollop",              "~> 2.1"
end

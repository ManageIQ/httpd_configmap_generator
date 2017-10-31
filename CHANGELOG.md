#Change Log

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)

## Unreleased as of Sprint 72 ending 2017-10-30

### Added
- Add ldap configmap generation [(#20)](https://github.com/ManageIQ/httpd_configmap_generator/pull/20)
- Removing restriction on -o output path. [(#8)](https://github.com/ManageIQ/httpd_configmap_generator/pull/8)
- Preferable to have the httpd-configmap-generator pod startup upon deployment [(#3)](https://github.com/ManageIQ/httpd_configmap_generator/pull/3)

### Fixed
- Fixed an --add-file option issue for the update subcommand [(#17)](https://github.com/ManageIQ/httpd_configmap_generator/pull/17)
- Fix how Trollop parsing was done [(#16)](https://github.com/ManageIQ/httpd_configmap_generator/pull/16)
- Fix bundler/setup so it can find the Gemfile [(#15)](https://github.com/ManageIQ/httpd_configmap_generator/pull/15)
- Allow loading other Gemfiles from bundler.d [(#14)](https://github.com/ManageIQ/httpd_configmap_generator/pull/14)
- Fix finding of the templates directory as a gem [(#12)](https://github.com/ManageIQ/httpd_configmap_generator/pull/12)
- Resources for the httpd_configmap_generator template were commented out. [(#10)](https://github.com/ManageIQ/httpd_configmap_generator/pull/10) 

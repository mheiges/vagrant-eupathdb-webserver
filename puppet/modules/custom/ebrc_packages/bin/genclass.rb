#!/usr/bin/env ruby

# TODO FOR PUPPET 4
#  - Class names containing hyphens are prohibited.
#  - apparently there's a limit on uppercase in class name
#   e.g. given ebrc_packages::perl_YAML, Puppet complains
#   "Could not find class ::ebrc_packages::perl_YAML"
#      Possible upstream ticket https://tickets.puppetlabs.com/browse/PUP-2823

# Generate a erbc_packages class file from the templates/class.erb.
# Usage:
#  genclass <package1> <package2> ...
#
# You can list multiple packages if necessary but the idea is that each class installs
# a single package. The class will be named as <package1>.

require 'erb'

template_dir="#{File.dirname(__FILE__)}/../templates"
manifest_dir="#{File.dirname(__FILE__)}/../manifests"

@packages = ARGV

template = File.open("#{template_dir}/class.erb", 'r').read

renderer = ERB.new(template)
#puts output = renderer.result()

File.open("#{manifest_dir}/#{@packages[0]}.pp", 'w+') { |file|
  file.write(renderer.result())
}
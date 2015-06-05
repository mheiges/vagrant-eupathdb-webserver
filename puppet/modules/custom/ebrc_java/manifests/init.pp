# == Class: ebrc_java
#
# Full description of class ebrc_java here.
#
# === Parameters
#
# Document parameters here.
#
# [*sample_parameter*]
#   Explanation of what this parameter affects and what it defaults to.
#   e.g. "Specify one or more upstream ntp servers as an array."
#
# === Variables
#
# Here you should define a list of variables that this module would require.
#
# [*sample_variable*]
#   Explanation of how this variable affects the function of this class and if
#   it has a default. e.g. "The parameter enc_ntp_servers must be set by the
#   External Node Classifier as a comma separated list of hostnames." (Note,
#   global variables should be avoided in favor of class parameters as
#   of Puppet 2.6.)
#
# === Examples
#
#  class { 'ebrc_java':
#    servers => [ 'pool.ntp.org', 'ntp.local.company.com' ],
#  }
#
# === Authors
#
# Author Name <author@domain.com>
#
# === Copyright
#
# Copyright 2015 Your name here, unless otherwise noted.
#
class ebrc_java {

  $packages = hiera('ebrc_java::packages')
  $java_home = hiera('ebrc_java::java_home')
  $java_keystore_target = hiera('java_keystore_target')

  package { $packages :
    ensure  => installed,
  }

  file { '/etc/profile.d/java.sh':
    ensure  => present,
    content => template('ebrc_java/java.sh'),
    require => Package[$packages],
  }

  # required dirs to make Oracle's jdk-1.7.0 compatible with CentOS's ant
  #file { ['/usr/share/java-1.7.0', '/usr/lib/java-1.7.0']:
  #  ensure  => directory,
  #  require => Class['::java'],
  #}

}
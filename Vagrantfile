
args = {}
#args[:hostname] = ARGV[1] || 'sa.apidb.org'
args[:hostname] = 'sa.apidb.org'

Vagrant.configure('2') do |config|

	config.vm.box = 'puppetlabs/centos-6.6-64-puppet'
  config.vm.box_url = 'https://atlas.hashicorp.com/puppetlabs/boxes/centos-6.6-64-puppet'

#  if Vagrant.has_plugin?('landrush')
#   config.landrush.enabled = true
#   config.landrush.tld = 'vm'
#  end

puts "Hostname: #{args[:hostname]}"
  config.vm.define args[:hostname] do |virtm|

    config.vm.hostname = "#{args[:hostname]}" 

    config.vm.network :forwarded_port, guest: 80, host: 1080, auto_correct: true
    config.vm.network :forwarded_port, guest: 443, host: 10443, auto_correct: true
 
    config.vm.provision :shell, :path   => "install-puppet-modules.sh"
    config.vm.provision :shell, :inline => "cp /vagrant/bash_history ~vagrant/.bash_history"
    config.vm.provision :shell, :inline => 'groupadd -g 300 tomcat'
    config.vm.provision :shell, :inline => "useradd -M -u 303 -s /sbin/nologin -d /usr/local/tomcat_instances/TemplateDB -c 'TemplateDB Tomcat instance owner' -g tomcat tomcat_3"

    config.vm.provision :puppet do |puppet|
      puppet.options = '--disable_warnings=deprecations'
      puppet.manifests_path = 'puppet/manifests'
      puppet.manifest_file = ''
      puppet.hiera_config_path = 'puppet/hiera.yaml'
      puppet.module_path = ['puppet/modules', 'puppet/modules/forge', 'puppet/modules/custom']
    end

    config.vm.provider :virtualbox do |v|
      v.name = "#{args[:hostname]}"
    end

  end

end

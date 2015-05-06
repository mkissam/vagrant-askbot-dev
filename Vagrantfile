# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  #config.vm.box = "precise64cloudimg"
  config.vm.box = "trusty64cloudimg"
  config.vm.box_url = "https://cloud-images.ubuntu.com/vagrant/trusty/current/trusty-server-cloudimg-amd64-vagrant-disk1.box"
  config.vm.hostname = "askbot-staging-dev.local"
  config.vm.network :private_network, ip: "192.168.27.141"
  config.vm.provider :virtualbox do |vb|
     vb.customize ["modifyvm", :id, "--memory", "2048"]
  end
  config.vm.provision :shell, :path => "scripts/bootstrap.sh"
  config.vm.provision "puppet" do |puppet|
    puppet.manifests_path = 'puppet/manifests'
    puppet.module_path = 'puppet/modules'
    puppet.manifest_file = 'site.pp'
    # puppet.options = '--verbose --debug'
  end
  # Uncomment those lines to use a local proxy
  # Requires vagrant plugin: vagrant-proxyconf (1.2.0)
  #config.proxy.http     = "http://192.168.27.1:3128/"
  #config.proxy.https    = "http://192.168.27.1:3128/"
  #config.proxy.no_proxy = "localhost,127.0.0.1"
end
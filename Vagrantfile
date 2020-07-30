
# -*- mode: ruby -*-
# # vi: set ft=ruby :
# Specify minimum Vagrant version and Vagrant API version
Vagrant.require_version ">= 2.2.4"
VAGRANTFILE_API_VERSION = "2"

# Require YAML module
require 'yaml'
# check existency of YAML file and Read them with their box details. 
# if File.exist?("secrets/mysec.yaml")
#   #credentials = YAML::load(File.open('secrets/mysec.yaml'))
#   credentials = YAML.load_file(File.join(File.dirname(__FILE__), 'secrets/mysec.yaml'))
#   #config.vm.provision :shell, :inline => "echo 'Acquire::http::Proxy \"http://#{proxy['user']}:#{proxy['pass']}@proxy.corp.com:3210\";' >> /etc/apt/apt.conf"
# end

if File.exist?("nodes/nodes.yaml")
  # check existency of YAML file and Read them with their box details. 
  #credentials = YAML::load(File.open('secrets/mysec.yaml'))
  nodes_config = YAML.load_file(File.join(File.dirname(__FILE__), 'nodes/nodes.yaml'))
  #config.vm.provision :shell, :inline => "echo 'Acquire::http::Proxy \"http://#{proxy['user']}:#{proxy['pass']}@proxy.corp.com:3210\";' >> /etc/apt/apt.conf"
end


Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = "ubuntu/bionic64"
  config.vm.synced_folder "shared_vagrant", "/vagrant"
  # Create boxes
  nodes_config["nodes"].each do |node|
    node_name = node["name"] # name of nodes
    node_ip = node[":ip"] # ip of nodes
    ports = node["ports"] # ports properties

    config.vm.define node_name do |config|
      # Configures all forwarding ports in YAML array
      ports.each do |port|
        config.vm.network :forwarded_port,
          host: port[":host"],
          guest: port[":guest"],
          id:    port[":id"]
      end
      # assign node names and ip addresses.
      config.vm.hostname = node_name
      config.vm.network :private_network, ip: node_ip
      
      config.vm.provider "virtualbox" do |vb|
        vb.customize ["modifyvm", :id, "--memory", node[':memory']]
        vb.customize ["modifyvm", :id, "--name", node_name]
      end
      config.vm.provision :reload
      config.vm.provision :shell, :path => node[':bootstrap']
    end
  end
end

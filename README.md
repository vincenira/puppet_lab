# Puppet lab projects

This purpose of this project is to install and configure puppet and learn the basic usage of puppet, and how automation goes in puppet.

The labs will consist of three nodes with one master, one worker and one node. it will be run in a virtualbox hypervisor with vagrant.
all the commands will be controlled via code. That means that we will use infrastructure as a code wherever it is possible.

## Default configuration of puppet server
This default configuration assigned to the puppet server settings for this labs.

```sh
sudo vi /etc/puppetlabs/puppet/puppet.conf
```

Place the following lines, Modify them to match your environment.

```sh
[master]
dns_alt_names = master.puppetvincelabs.com,master

[main]
certname = master.puppetvincelabs.com
server = master.puppetvincelabs.com
environment = production
runinterval = 15m
```

## Default configuration of puppet agent
This default configuration assigned to the puppet agent settings for this labs.

```sh
sudo vi /etc/puppetlabs/puppet/puppet.conf
```

Place the following lines, Modify them to match your environment.

```sh

[main]
certname = client.puppetvincelabs.com
server = master.puppetvincelabs.com
environment = production
runinterval = 15m
```

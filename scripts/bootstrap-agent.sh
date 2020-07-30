#!/bin/sh
#title           : bootstrap-agent.sh
#description     : This script will bootstrap installation and configuration of puppet agent nodes on ubuntu.
#author		     : vincenira
#date            : 2020729
#version         : 0.1    
#usage		     : sh bootstrap-agent.sh
#notes           : Install Vim and Emacs to use this script.
#bash_version    : 0.0.1-unreleased
#==============================================================================
export DEBIAN_FRONTEND=noninteractive
config_etc()
{
        echo "" | sudo tee --append /etc/hosts 2> /dev/null && \
        echo "# Host config for Puppet Master and Agent Nodes" | sudo tee --append /etc/hosts 2> /dev/null && \
        echo "192.168.56.15   master.puppetvincelabs.com  master" | sudo tee --append /etc/hosts 2> /dev/null && \
        echo "192.168.56.25   node01.puppetvincelabs.com  node01" | sudo tee --append /etc/hosts 2> /dev/null && \
        echo "192.168.56.35   node02.puppetvincelabs.com  node02" | sudo tee --append /etc/hosts 2> /dev/null
}

config_puppet_conf()
{
        echo "" | sudo tee --append /etc/puppetlabs/puppet/puppet.conf 2> /dev/null && \
        echo "[main]" | sudo tee --append /etc/puppetlabs/puppet/puppet.conf 2> /dev/null && \
        echo "certname = $(hostname -f)" | sudo tee --append /etc/puppetlabs/puppet/puppet.conf 2> /dev/null && \
        echo "server = master.puppetvincelabs.com" | sudo tee --append /etc/puppetlabs/puppet/puppet.conf 2> /dev/null && \
        echo "environment = production" | sudo tee --append /etc/puppetlabs/puppet/puppet.conf 2> /dev/null
        echo "runinterval = 15m" | sudo tee --append /etc/puppetlabs/puppet/puppet.conf 2> /dev/null
}

enable_puppet()
{
    sudo /opt/puppetlabs/bin/puppet resource service puppet ensure=running enable=true
}

installer_git()
{

    sudo DEBIAN_FRONTEND=noninteractive apt-get update -yq 
    sudo DEBIAN_FRONTEND=noninteractive apt-get upgrade -yq
    sudo DEBIAN_FRONTEND=noninteractive apt-get install git -yq
}

installer_puppet_agent()
{
    wget https://apt.puppetlabs.com/puppet6-release-bionic.deb
    sudo dpkg -i puppet6-release-bionic.deb
    sudo DEBIAN_FRONTEND=noninteractive apt-get update -yq 
    sudo DEBIAN_FRONTEND=noninteractive apt-get upgrade -yq
    sudo DEBIAN_FRONTEND=noninteractive apt-get install -yq puppet-agent
}

installer_ntp()
{
    sudo DEBIAN_FRONTEND=noninteractive apt-get update -yq 
    sudo DEBIAN_FRONTEND=noninteractive apt-get install -yq ntp ntpdate
    sudo ntpdate -u 0.ubuntu.pool.ntp.org
    date && timedatectl list-timezones && sudo timedatectl set-timezone America/New_York
}
# Run on  VM to bootstrap Puppet Agent nodes

if ps aux | grep "puppet agent" | grep -v grep 2> /dev/null; then
    echo "Puppet Agent is already installed. Moving on..."
    # Configure /etc/hosts file
    if cat /etc/hosts | grep "puppetvincelabs.com" 2> /dev/null; then
        exit 0
    else
        config_etc
        enable_puppet
        installer_git
        exit 0
    fi 
else
    installer_ntp
    installer_puppet_agent
    installer_git
    config_etc
    config_puppet_conf
    enable_puppet
fi

# if cat /etc/crontab | grep puppet 2> /dev/null; then
#     echo "Puppet Agent is already configured. Existing..."
#     exit 0
# else
#     # Add a cron from puppet to run every 30 mins.
#         sudo puppet resource cron puppet-agent ensure=present user=root minute 30 \
#         command='/usr/bin/puppet agent --onetime --no-daemonize --splay'

#         sudo puppet resource service puppet ensure=running enable=true
#         # Configure /etc/hosts file
#         config_etc
#         # Add agent section to /etc/puppet/puppet.conf
#         echo "" && echo "[agent]\nserver=master" | sudo tee --append /etc/puppet/puppet.conf 2> /dev/null
#         sudo puppet agent --enable
# fi
# # Enable puppet and give puppet time to auto sign the certificate and kick off a run.
#     sudo puppet agent --enable
#     sudo puppet agent -t --waitforcert 15

# added the code below as puppet runs produced a non-zero exist
exit 0
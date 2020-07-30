#!/bin/sh
#title           : bootstrap-master.sh
#description     : This script will bootstrap installation and configuration of puppet master nodes on ubuntu.
#author		     : vincenira
#date            : 2020729
#version         : 0.1    
#usage		     : sh bootstrap-master.sh
#notes           : Install Vim and Emacs to use this script.
#bash_version    : 0.0.1-unreleased
#==============================================================================

# Run on VM to bootstrap Puppet Master Server
export DEBIAN_FRONTEND=noninteractive
installer_ntp()
{
    sudo apt-get update -yq && sudo apt-get install -yq ntp ntpdate
    sudo ntpdate -u 0.ubuntu.pool.ntp.org
    date && timedatectl list-timezones && sudo timedatectl set-timezone America/New_York
}

if ps aux | grep "puppet master" | grep -v grep 2> /dev/null; then
    
    echo "Puppet Master is already installed. Existing"
    exit 0
else
    # Install NTP client
    installer_ntp
    # Install Puppet Master
    wget https://apt.puppetlabs.com/puppet6-release-bionic.deb
    sudo dpkg -i puppet6-release-bionic.deb
    sudo DEBIAN_FRONTEND=noninteractive apt-get update -yq 
    sudo DEBIAN_FRONTEND=noninteractive apt-get upgrade -yq  
    sudo DEBIAN_FRONTEND=noninteractive apt-get install -yq puppetserver
    # Add optional alternate DNS names to /etc/puppetlabs/puppet/puppet.conf
    if [ -e "/etc/puppetlabs/puppet/puppet.conf" ]; then
        if grep -Fxq "\[main\]" /etc/puppetlabs/puppet/puppet.conf 
        then
            sudo sed -i 's/.*\[master\].*/&\ndns_alt_names = master,master.puppetvincelabs.com/' /etc/puppetlabs/puppet/puppet.conf
            sudo sed -i 's/.*\[master\].*/&\nautosign = true/' /etc/puppetlabs/puppet/puppet.conf
        else
            sudo sed -i 's/.*\[master\].*/&\ndns_alt_names = master,master.puppetvincelabs.com/' /etc/puppetlabs/puppet/puppet.conf
            sudo sed -i 's/.*\[master\].*/&\nautosign = true/' /etc/puppetlabs/puppet/puppet.conf
            echo "[main]" | sudo tee --append /etc/puppetlabs/puppet/puppet.conf 2> /dev/null && \
            echo "certname = $(hostname -f)" | sudo tee --append /etc/puppetlabs/puppet/puppet.conf 2> /dev/null && \
            echo "server = master.puppetvincelabs.com" | sudo tee --append /etc/puppetlabs/puppet/puppet.conf 2> /dev/null && \
            echo "environment = production" | sudo tee --append /etc/puppetlabs/puppet/puppet.conf 2> /dev/null
            echo "runinterval = 15m" | sudo tee --append /etc/puppetlabs/puppet/puppet.conf 2> /dev/null
        fi 
    fi
    sudo systemctl enable puppetserver && sudo systemctl start puppetserver
fi
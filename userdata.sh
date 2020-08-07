#!/bin/bash
IP=`ip -o -4 addr show dev eth0 | cut -d ' ' -f 7 | cut -f 1 -d '/'`
if [ "$IP" == "172.30.0.10" ]; then
    hostnamectl set-hostname --static wazuh-manager
fi
if [ "$IP" == "172.30.0.20" ]; then
    hostnamectl set-hostname --static elastic-server
fi
if [ "$IP" == "172.30.0.30" ]; then
    hostnamectl set-hostname --static linux-agent
fi
echo "preserve_hostname: true" >> /etc/cloud/cloud.cfg
echo "172.30.0.10 wazuh-manager" >> /etc/hosts
echo "172.30.0.20 elastic-server" >> /etc/hosts
echo "172.30.0.30 linux-agent" >> /etc/hosts
echo "172.30.0.40 windows-agent" >> /etc/hosts
echo "PATH=$PATH:$HOME/bin:/var/ossec/bin" >> /root/.bashrc
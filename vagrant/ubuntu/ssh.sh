#!/bin/bash

# Enable password auth in sshd so we can use ssh-copy-id
sed -i --regexp-extended 's/#?PasswordAuthentication (yes|no)/PasswordAuthentication yes/' /etc/ssh/sshd_config
sed -i --regexp-extended 's/#?Include \/etc\/ssh\/sshd_config.d\/\*.conf/#Include \/etc\/ssh\/sshd_config.d\/\*.conf/' /etc/ssh/sshd_config
sed -i 's/KbdInteractiveAuthentication no/KbdInteractiveAuthentication yes/' /etc/ssh/sshd_config
systemctl restart sshd

if [ ! -d /home/vagrant/.ssh ]
then
    mkdir /home/vagrant/.ssh
    chmod 700 /home/vagrant/.ssh
    chown vagrant:vagrant /home/vagrant/.ssh
fi

# TODO: move this code into dedicated file, like `services_cleanup.sh`
# Disable all auto-fetch activity:
systemctl disable motd-news.timer
systemctl disable ubuntu-advantage.service
systemctl stop apt-daily.timer
systemctl disable apt-daily.timer
systemctl disable apt-daily.service
systemctl disable unattended-upgrades.service
systemctl stop unattended-upgrades.service

# TODO: probably we don't need this part at all:
if [ "$(hostname)" = "controlplane01" ]
then
    # sh -c 'sudo apt update' &> /dev/null
    # sh -c 'sudo apt-get install -y sshpass' &> /dev/null
    apt-get -qq update
    apt-get install -y -V sshpass
fi


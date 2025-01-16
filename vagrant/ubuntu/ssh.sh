#!/bin/bash

sed -i --regexp-extended 's/#?Include \/etc\/ssh\/sshd_config.d\/\*.conf/#Include \/etc\/ssh\/sshd_config.d\/\*.conf/' /etc/ssh/sshd_config

cat << 'EOF' > /etc/ssh/sshd_config.d/my_vagrant_lab.conf
# Enable password auth in sshd so we can use ssh-copy-id
PasswordAuthentication yes
KbdInteractiveAuthentication yes
EOF
systemctl restart sshd

if [ ! -d /home/vagrant/.ssh ]
then
    mkdir /home/vagrant/.ssh
    chmod 700 /home/vagrant/.ssh
    chown vagrant:vagrant /home/vagrant/.ssh
fi

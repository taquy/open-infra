#!/bin/bash

cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak
cat <<EOF > /etc/ssh/sshd_config
PermitRootLogin yes
StrictModes no
MaxAuthTries 5
MaxSessions 3

PubkeyAuthentication yes

ChallengeResponseAuthentication no

UsePAM no

X11Forwarding yes
PrintMotd no
AcceptEnv LANG LC_*

PasswordAuthentication no
EOF

service sshd restart
systemctl reload ssh

# make sure root has same ssh config

cp -r /home/qt/.ssh/* /root/.ssh
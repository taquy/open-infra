
# edit /etc/network/interfaces
systemctl restart network

# edit /etc/hosts
service pve-cluster restart

# edit /etc/pve/corosync.conf (optional)
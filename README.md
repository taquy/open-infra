
# Start procedure
kubespray > gluster > heketi

# Remove line in /root/.ssh/authorized_keys for all machines
Tips: use ctrl+shift+6 to set mark
no-port-forwarding,no-agent-forwarding,no-X11-forwarding,command="echo 'Please login as the user \"ubuntu\" rather than the user \"root\".';echo;sleep 10"\

# TODO
- generate separate ssh key for heketi user
- generate separate ssh key for ansible user 
- gluster inventory could be simplified
- try to use virtual disk rather than mounting an external disk (this is for fully independent from cloud providers)
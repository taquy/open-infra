

# install gluster installation playbook
ansible-playbook -i inventory-glusterfs.ini -b -v --private-key=/root/.ssh/taquy-vm install-gluster.yml
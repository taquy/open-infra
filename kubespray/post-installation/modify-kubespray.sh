
# reset cluster
cd ~/kubespray
ansible-playbook --become -e ansible_ssh_user=root \
  -i inventory/mycluster/hosts.yaml \
  -b -v --private-key=/root/.ssh/taquy-vm \
  reset.yml

# update cluster
ansible-playbook --become -e ansible_ssh_user=root \
  -i inventory/mycluster/hosts.yaml \
  -b -v --private-key=/root/.ssh/taquy-vm \
  -e upgrade_cluster_setup=true \
  cluster.yml

# install cluster
ansible-playbook --become -e ansible_ssh_user=root \
  -i inventory/mycluster/hosts.yaml \
  -b -v --private-key=/root/.ssh/taquy-vm \
  cluster.yml
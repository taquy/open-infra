#!/bin/bash
cd ~/kubespray

# install cluster
ansible-playbook --become -e ansible_ssh_user=root \
  -i inventory/mycluster/hosts.yaml \
  -b -v --private-key=/root/.ssh/id_rsa \
  cluster.yml


# update cluster
ansible-playbook --become -e ansible_ssh_user=root \
  -i inventory/mycluster/hosts.yaml \
  -b -v --private-key=/root/.ssh/id_rsa \
  -e upgrade_cluster_setup=true \
  cluster.yml

# reset cluster
ansible-playbook --become -e ansible_ssh_user=root \
  -i inventory/mycluster/hosts.yaml \
  -b -v --private-key=/root/.ssh/id_rsa \
  reset.yml

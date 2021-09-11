# define instance IPs
declare -a IPS=(10.0.2.155 10.0.2.111 10.0.2.138)

# install cluster
## prepare hosts file
CONFIG_FILE=inventory/mycluster/hosts.yaml 
python3 contrib/inventory_builder/inventory.py ${IPS[@]}

## install cluster
ansible-playbook --become -e ansible_ssh_user=root -i inventory/mycluster/hosts.yaml  cluster.yml -b -v --private-key=/root/.ssh/taquy-vm

## check nodes
kubectl get nodes

# install firewalls
## create script
cat <<EOF > install-firewall.sh
apt install -y firewalld
firewall-cmd --zone=public --permanent --add-port=2379-2380/tcp --permanent
firewall-cmd --zone=public --permanent --add-port=10250/tcp --permanent
firewall-cmd --zone=public --permanent --add-port=10251/tcp --permanent
firewall-cmd --zone=public --permanent --add-port=10252/tcp --permanent
firewall-cmd --zone=public --permanent --add-port=10250/tcp --permanent
firewall-cmd --zone=public --permanent --add-port=30000-32767/tcp --permanent
firewall-cmd --reload
EOF

## create playbook
cat <<EOF > install-firewall.yml
- name: Transfer and execute a script.
  hosts: all
  remote_user: root
  tasks:
     - name: Transfer the script
       copy: src=install-firewall.sh dest=/root mode=0777
     - name: Execute the script
       command: sh /root/install-firewall.sh
EOF

ansible-playbook -i $CONFIG_FILE -b -v --private-key=/root/.ssh/taquy-vm install-firewall.yml

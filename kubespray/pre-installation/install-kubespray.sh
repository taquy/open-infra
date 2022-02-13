# define instance IPs (must existed in network interface)
declare -a IPS=(10.0.2.62 10.0.2.229 10.0.2.40)

# install cluster
## prepare hosts file
cd kubespray
CONFIG_FILE=inventory/mycluster/hosts.yaml python3 contrib/inventory_builder/inventory.py ${IPS[@]}
CONFIG_FILE=inventory/mycluster/hosts.yaml

## install cluster (requires root access and use root to execute)
ansible-playbook --become -e ansible_ssh_user=root \
  -i $CONFIG_FILE \
  -b -v --private-key=/root/.ssh/id_rsa \
  cluster.yml

## check nodes
kubectl get nodes

# install firewalls
## create script
cat <<EOF > install-firewall.sh
systemctl enable docker.service

apt install -y firewalld
systemctl start firewalld
systemctl enable firewalld

firewall-cmd --zone=public --permanent --add-port=2379-2380/tcp --permanent
firewall-cmd --zone=public --permanent --add-port=8080/tcp --permanent
firewall-cmd --zone=public --permanent --add-port=4789/tcp --permanent
firewall-cmd --zone=public --permanent --add-port=4149/tcp --permanent
firewall-cmd --zone=public --permanent --add-port=5473/tcp --permanent
firewall-cmd --zone=public --permanent --add-port=6443/tcp --permanent
firewall-cmd --zone=public --permanent --add-port=10250-10256/tcp --permanent
firewall-cmd --zone=public --permanent --add-port=30000-32767/tcp --permanent

firewall-cmd --zone=public --permanent --add-port=9100-9101/tcp --permanent
firewall-cmd --zone=public --permanent --add-port=5757/tcp --permanent

# calico
firewall-cmd --zone=public --permanent --add-port=9099/tcp --permanent
firewall-cmd --zone=public --permanent --add-port=179/tcp --permanent

# http
firewall-cmd --zone=public --permanent --add-port=80/tcp --permanent
firewall-cmd --zone=public --permanent --add-port=443/tcp --permanent
firewall-cmd --zone=public --permanent --add-port=8443/tcp --permanent

# coredns
firewall-cmd --zone=public --permanent --add-port=8081/tcp --permanent

firewall-cmd --reload
systemctl status firewalld

calicoctl node status

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
cat install-firewall.yml
ansible-playbook -i $CONFIG_FILE -b -v --private-key=/root/.ssh/id_rsa install-firewall.yml


# fix access to control api server
cat <<EOF > fix-access-apiserver.sh
systemctl stop kubelet
iptables --flush
iptables -tnat --flush
systemctl start kubelet
EOF

## create playbook
cat <<EOF > fix-access-apiserver.yml
- name: Transfer and execute a script.
  hosts: all
  remote_user: root
  tasks:
     - name: Transfer the script
       copy: src=fix-access-apiserver.sh dest=/root mode=0777
     - name: Execute the script
       command: sh /root/fix-access-apiserver.sh
EOF
cat fix-access-apiserver.yml
ansible-playbook -i $CONFIG_FILE -b -v --private-key=/root/.ssh/id_rsa fix-access-apiserver.yml

# remove everything kubernetes
# fix access to control api server
cat <<EOF > full-clean.sh
sudo rm -rf /etc/kubernetes
EOF

## create playbook
cat <<EOF > full-clean.yml
- name: Transfer and execute a script.
  hosts: all
  remote_user: root
  tasks:
     - name: Transfer the script
       copy: src=full-clean.sh dest=/root mode=0777
     - name: Execute the script
       command: sh /root/full-clean.sh
EOF
cat full-clean.yml
ansible-playbook -i $CONFIG_FILE -b -v --private-key=/root/.ssh/id_rsa full-clean.yml
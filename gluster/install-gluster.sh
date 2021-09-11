
# generate gcluster
cat <<EOF > install-gluster.sh
apt install -y software-properties-common
add-apt-repository ppa:gluster/glusterfs-7 -y
apt update
apt install -y glusterfs-server glusterfs-client rpcbind thin-provisioning-tools
for i in dm_snapshot dm_mirror dm_thin_pool loop; do modprobe $i; done
for i in dm_snapshot dm_mirror dm_thin_pool loop; do echo $i | tee -a /etc/modules; done
cat /etc/modules
lsmod | egrep 'dm_snapshot|dm_mirror|dm_thin_pool'
systemctl enable glusterd && systemctl start glusterd && systemctl status glusterd
systemctl enable rpcbind && systemctl start rpcbind && systemctl status rpcbind

# firewall installation
apt install -y firewalld
firewall-cmd --zone=public --add-port=24007-24008/tcp --permanent
firewall-cmd --zone=public --add-port=24009/tcp --permanent
firewall-cmd --zone=public --add-service=nfs --add-service=samba --add-service=samba-client --permanent
firewall-cmd --zone=public --add-port=111/tcp --add-port=139/tcp --add-port=445/tcp --add-port=965/tcp --add-port=2049/tcp --add-port=38465-38469/tcp --add-port=631/tcp --add-port=111/udp --add-port=963/udp --add-port=49152-49251/tcp --permanent
firewall-cmd --reload

# install utilities
apt install -y net-tools htop unzip git
EOF

# generate inventory
IPS_STR=$(kubectl get nodes -o jsonpath={.items[*].status.addresses[?\(@.type==\"InternalIP\"\)].address})
NAMES_STR=$(kubectl get nodes -o jsonpath={.items[*].metadata.name})
declare -a IPS=()
cat /etc/modules
read -ra ADDR <<< "$IPS_STR"
for i in "${ADDR[@]}"; do IPS+=("$i"); done
declare -a NAMES=()
read -ra ADDR <<< "$NAMES_STR"
for i in "${ADDR[@]}"; do NAMES+=("$i"); done

echo ${IPS[@]}
echo ${NAMES[@]}

rm inventory.ini 2> /dev/null

for i in "${!NAMES[@]}";
do
echo ''${NAMES[$i]}' ansible_ssh_host='${IPS[$i]}' ip='${IPS[$i]}' ansible_ssh_user=root'>>inventory.ini
done

echo "[gfs-cluster]" >> inventory.ini
for i in "${!NAMES[@]}"; do echo ${NAMES[$i]}>>inventory.ini; done

echo '[network-storage:children]
gfs-cluster'>>inventory.ini
cat inventory.ini

cat <<EOF > install-gluster.yml
- name: Transfer and execute a script.
  hosts: gfs-cluster
  remote_user: root
  tasks:
     - name: Transfer the script
       copy: src=/root/install-gluster.sh dest=/root mode=0777
     - name: Execute the script
       command: sh /root/install-gluster.sh
EOF
cat install-gluster.yml

# execute playbook
ansible-playbook -i inventory.ini -b -v --private-key=/root/.ssh/taquy-vm install-gluster.yml

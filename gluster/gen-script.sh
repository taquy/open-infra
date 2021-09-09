cat <<EOF > install-gluster.sh
apt install -y software-properties-common
add-apt-repository ppa:gluster/glusterfs-7 -y
apt update
apt install -y glusterfs-server glusterfs-client rpcbind
for i in dm_snapshot dm_mirror dm_thin_pool loop; do modprobe $i; done
for i in dm_snapshot dm_mirror dm_thin_pool loop; do echo $i | tee -a /etc/modules; done
lsmod |  egrep 'dm_snapshot|dm_mirror|dm_thin_pool'
apt install -y thin-provisioning-tools
systemctl enable glusterd && systemctl start glusterd && systemctl status glusterd
systemctl enable rpcbind && systemctl start rpcbind && systemctl status rpcbind

# firewall installation
apt install -y firewalld
firewall-cmd --zone=public --add-port=24007-24008/tcp --permanent
firewall-cmd --zone=public --add-port=24009/tcp --permanent
firewall-cmd --zone=public --add-service=nfs --add-service=samba --add-service=samba-client --permanent
firewall-cmd --zone=public --add-port=111/tcp --add-port=139/tcp --add-port=445/tcp --add-port=965/tcp --add-port=2049/tcp --add-port=38465-38469/tcp --add-port=631/tcp --add-port=111/udp --add-port=963/udp --add-port=49152-49251/tcp --permanent
firewall-cmd --reload
EOF

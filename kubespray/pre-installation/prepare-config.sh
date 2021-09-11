# this script is to be run at local machine to prepare zip file

#copy key to remote host
scp -i ~/.ssh/taquy-vm ~/.ssh/taquy-vm root@$REMOTE_HOST:/root/.ssh

#copy key to cluster client machine
ssh-copy-id -i ~/.ssh/taquy-vm ubuntu@$CLIENT_HOST
scp -i ~/.ssh/taquy-vm ~/.ssh/taquy-vm ubuntu@$CLIENT_HOST:~/.ssh

# clone repository
git clone https://github.com/kubernetes-sigs/kubespray.git
cd kubespray
pip install -r requirements.txt
cp -rfp inventory/sample inventory/mycluster

cat inventory/mycluster/group_vars/all/all.yml
cat inventory/mycluster/group_vars/k8s_cluster/k8s-cluster.yml

cd inventory/mycluster/group_vars/

: '
> all.yml
kube_read_only_port: 10255
etcd_kubeadm_enabled: true
loadbalancer_apiserver:
   address: 1.2.3.4 # use public ip of control plane node
   port: 6443
> k8s-cluster.yml
cluster_name: taquy
'

cd ~/Downloads
rm kubespray.zip
zip -r ~/Downloads/kubespray kubespray
scp -i ~/.ssh/taquy-vm -r ~/Downloads/kubespray.zip root@$REMOTE_HOST:/root

# On remote host, in /root
rm -r kubespray
unzip kubespray.zip
cd kubespray
pip install -r requirements.txt	

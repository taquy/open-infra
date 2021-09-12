# pre conditions
- the installation script required to have kubernetes cluster installed since it's using get nodes API to collect IPs and hostnames of all nodes within cluster

# Steps for installation
install-heketi.sh
install-topology.sh
- make sure update common device name, admin key, user key according to your like

# Steps for demo
demo/create-storage-class.sh
- this will generate a storage class and a sample persistent volume claims
demo/deploy-mongodb.sh
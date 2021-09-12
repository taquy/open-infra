
# pre conditions
- the installation script required to have kubernetes cluster installed since it's using get nodes API to collect IPs and hostnames of all nodes within cluster

# the script containing following steps 
1. preparing installation script
- install glusterd 
- install firewall
2. preparing inventory
- collecting IPs/hostnames from kubernetes control pane
- create inventory file
3. preparing playbook
- playbook contains step to copy script and step to execute script on remote machine
4. execute playbook
5. peering node to cluster
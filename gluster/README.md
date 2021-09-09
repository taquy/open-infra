
# preparing inventory
gen-inventory.sh

note: sample result of inventory is `inventory.ini`

# preparing playbook
gen-playbook.sh

# preparing installation script
gen-script.sh

# install gluster installation playbook
ansible-playbook -i inventory.ini -b -v --private-key=/root/.ssh/taquy-vm install-gluster.yml

# peering cluster (from master node)
peering.sh
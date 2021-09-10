# ref:
# https://unixcop.com/how-to-create-a-virtual-hard-disk-in-ubuntu/

# create script to create virtual hard disk
echo '
# create 10 GB image
dd if=/dev/zero of=/media/gluster.img bs=1M count=10240
# format disk
mkfs -t ext4 -F /media/gluster.img
# create the loopback block device 
# where 7 is the major number of loop device driver, grep loop /proc/devices
mknod /dev/gluster b 7 200 
losetup /dev/gluster /media/gluster.img
wipefs -a /dev/gluster
' > install-vhd.sh
cat install-vhd.sh

## create playbook
cat <<EOF > install-vhd.yml
- name: Transfer and execute a script.
  hosts: all
  remote_user: root
  tasks:
     - name: Transfer the script
       copy: src=install-vhd.sh dest=/root mode=0777
     - name: Execute the script
       command: sh /root/install-vhd.sh
EOF
cat install-vhd.yml

## create host file
NAMES_STR=$(kubectl get nodes -o jsonpath={.items[*].metadata.name})
declare -a NAMES=()
read -ra ADDR <<< "$NAMES_STR"
for i in "${ADDR[@]}"; do NAMES+=("$i"); done
echo '' > hosts
for i in "${!NAMES[@]}"; do echo ${NAMES[$i]} >> hosts; done
cat hosts

## run playbook
ansible-playbook -i hosts -b -v --private-key=/root/.ssh/taquy-vm install-vhd.yml

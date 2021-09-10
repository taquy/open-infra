# ref:
# https://unixcop.com/how-to-create-a-virtual-hard-disk-in-ubuntu/

# create script to create virtual hard disk
echo '
# create 10 GB image
dd if=/dev/zero of=/media/gluster.img bs=1M count=10240
# format disk
mkfs -t ext4 /media/gluster.img
# mount volume
mkdir /mnt/gluster/
mount -t auto -o loop /media/gluster.img /mnt/gluster/ 
# append automount to fstab
if ! grep -q "gluster" /etc/fstab ; then
    echo "# gluster" >> /etc/fstab
    echo "/media/gluster.img    /mnt/gluster/    ext4    defaults      0        0" >> /etc/fstab
fi
df -hT
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

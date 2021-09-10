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
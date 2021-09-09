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
cat<<EOF>playbook.yml
---
- name: Generate Heketi topology file and copy to Heketi Server
  hosts: node1
  become: yes
  become_method: sudo
  roles:
    - heketi
EOF

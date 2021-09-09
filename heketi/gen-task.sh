cat<<EOF>task.yml
---
- name: Copy heketi topology file
  template:
    src: topology.json.j2
    dest: /etc/heketi/topology.json
- name: Set proper file ownership
  file:
   path:  /etc/heketi/topology.json
   owner: heketi
   group: heketi
EOF

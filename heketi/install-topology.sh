echo '
{
  "clusters": [
    {
      "nodes": [
      {% if gluster_servers is defined and gluster_servers is iterable %}
      {% for item in gluster_servers %}
        {
          "node": {
            "hostnames": {
              "manage": [
                "{{ item.servername }}"
              ],
              "storage": [
                "{{ item.serverip }}"
              ]
            },
            "zone": {{ item.zone }}
          },
          "devices": [
            "{{ item.disks | list | join ("\",\"") }}"
          ]
        }{% if not loop.last %},{% endif %}
    {% endfor %}
    {% endif %}
      ]
    }
  ]
}
' > topology.json.j2

echo '
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
' > task.yml

IPS_STR=$(kubectl get nodes -o jsonpath={.items[*].status.addresses[?\(@.type==\"InternalIP\"\)].address})
NAMES_STR=$(kubectl get nodes -o jsonpath={.items[*].metadata.name})

declare -a IPS=()
read -ra ADDR <<< "$IPS_STR"
for i in "${ADDR[@]}"; do IPS+=("$i"); done

declare -a NAMES=()
read -ra ADDR <<< "$NAMES_STR"
for i in "${ADDR[@]}"; do NAMES+=("$i"); done

echo "gluster_servers:">topology-values.yml
for i in "${!NAMES[@]}";
do
	echo '
	  - servername: ${NAMES[$i]}
	    serverip: ${IPS[$i]}
	    zone: 1
	    disks:
	      - /data/gv0
	' >> topology-values.yml
done
cat topology-values.yml

ansible-playbook -i inventory-glusterfs.ini --user root --private-key=/root/.ssh/taquy-vm  ~/projects/ansible/heketi.yml
cat /etc/heketi/topology.json 
# load topology
heketi-cli topology load --user admin --secret "ZRl4d6Vtt5WCqgFB" --json=/etc/heketi/topology.json


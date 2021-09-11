# ref: 
# https://computingforgeeks.com/setup-glusterfs-storage-with-heketi-on-centos-server/

# prepare topology template
mkdir -p ansible/roles/heketi/{tasks,templates,defaults}

echo '{
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
}' > ansible/roles/heketi/templates/topology-template.yml
cat ansible/roles/heketi/templates/topology-template.yml

# prepare topology values
IPS_STR=$(kubectl get nodes -o jsonpath={.items[*].status.addresses[?\(@.type==\"InternalIP\"\)].address})
NAMES_STR=$(kubectl get nodes -o jsonpath={.items[*].metadata.name})

declare -a IPS=()
read -ra ADDR <<< "$IPS_STR"
for i in "${ADDR[@]}"; do IPS+=("$i"); done

declare -a NAMES=()
read -ra ADDR <<< "$NAMES_STR"
for i in "${ADDR[@]}"; do NAMES+=("$i"); done

echo "gluster_servers:">ansible/roles/heketi/defaults/main.yml
for i in "${!NAMES[@]}";
do
	echo '  - servername: '${NAMES[$i]}'
    serverip: '${IPS[$i]}'
    zone: 1
    disks:
      - /mnt/gluster/' >> ansible/roles/heketi/defaults/main.yml
  # update known hosts
  ssh-keyscan -H ${NAMES[$i]} > /etc/ssh/ssh_known_hosts
  ssh-keyscan -H ${IPS[$i]} > /etc/ssh/ssh_known_hosts
  ssh-keyscan -H ${NAMES[$i]} > ~/.ssh/known_hosts
  ssh-keyscan -H ${IPS[$i]} > ~/.ssh/known_hosts
done
cat /etc/ssh/ssh_known_hosts
cat ansible/roles/heketi/defaults/main.yml

echo '
SSH_KNOWN_HOSTS=/etc/ssh/ssh_known_hosts
' >> ~/.bashrc
source ~/.bashrc
# prepare topology playbook task
echo '---
- name: Copy heketi topology file
  template:
    src: topology-template.yml
    dest: /etc/heketi/topology.json
- name: Set proper file ownership
  file:
   path:  /etc/heketi/topology.json
   owner: heketi
   group: heketi
' > ansible/roles/heketi/tasks/main.yml
cat ansible/roles/heketi/tasks/main.yml

# prepare topology playbook
echo '---
- name: Generate Heketi topology file and copy to Heketi Server
  hosts: node1
  become: yes
  become_method: sudo
  roles:
    - heketi
' > ansible/playbook.yml
cat ansible/playbook.yml

# prepare hosts
echo '' > ansible/hosts
for i in "${!NAMES[@]}"; do echo ${NAMES[$i]} >> ansible/hosts; done
cat ansible/hosts

# execute playbook for topology templating
ansible-playbook -i ansible/hosts --private-key=/root/.ssh/taquy-vm ansible/playbook.yml
cat /etc/heketi/topology.json 

# load topology to heketi
heketi-cli topology load --user $HEKETI_CLI_USER --secret "${HEKETI_CLI_KEY}" --json=/etc/heketi/topology.json


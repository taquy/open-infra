IPS_STR=$(kubectl get nodes -o jsonpath={.items[*].status.addresses[?\(@.type==\"InternalIP\"\)].address})
NAMES_STR=$(kubectl get nodes -o jsonpath={.items[*].metadata.name})
declare -a IPS=()
read -ra ADDR <<< "$IPS_STR"
for i in "${ADDR[@]}"; do IPS+=("$i"); done
declare -a NAMES=()
read -ra ADDR <<< "$NAMES_STR"
for i in "${ADDR[@]}"; do NAMES+=("$i"); done

echo ${IPS[@]}
echo ${NAMES[@]}


rm inventory.ini 2> /dev/null
for i in "${!NAMES[@]}";
do
cat<<EOF>>inventory.ini
${NAMES[$i]} ansible_ssh_host=${IPS[$i]} ip=${IPS[$i]} ansible_ssh_user=root
EOF
done

echo "[gfs-cluster]" >> inventory.ini
for i in "${!NAMES[@]}";
do
cat<<EOF>>inventory.ini
${NAMES[$i]}
EOF
done

cat<<EOF>>inventory.ini
[network-storage:children]
gfs-cluster
EOF

cat inventory.ini


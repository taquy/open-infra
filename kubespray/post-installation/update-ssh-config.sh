IPS_STR=$(kubectl get nodes -o jsonpath={.items[*].status.addresses[?\(@.type==\"InternalIP\"\)].address})
NAMES_STR=$(kubectl get nodes -o jsonpath={.items[*].metadata.name})

for i in $IPS_STR; do ssh-keyscan $i >> ~/.ssh/known_hosts; done
for i in $NAMES_STR; do ssh-keyscan $i >> ~/.ssh/known_hosts; done

declare -a IPS=()
read -ra ADDR <<< "$IPS_STR"
for i in "${ADDR[@]}"; do IPS+=("$i"); done
declare -a NAMES=()
read -ra ADDR <<< "$NAMES_STR"
for i in "${ADDR[@]}"; do NAMES+=("$i"); done

for i in "${!NAMES[@]}";
do
cat<<EOF>>~/.ssh/config
Host ${NAMES[$i]}
  HostName ${NAMES[$i]}
  User root
  Port 22
  IdentityFile /root/.ssh/taquy-vm
  IdentitiesOnly yes
EOF
done

cat ~/.ssh/config
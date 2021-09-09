INTERNAL_IPS=$(kubectl get nodes -o jsonpath={.items[*].status.addresses[?\(@.type==\"InternalIP\"\)].address})
for i in $INTERNAL_IPS; do gluster peer probe $i; done
gluster peer status
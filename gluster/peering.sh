INTERNAL_IPS=$(kubectl get nodes -o jsonpath={.items[*].status.addresses[?\(@.type==\"InternalIP\"\)].address})
for i in $INTERNAL_IPS; do gluster peer probe $i; done
gluster peer status

BRICKS=""
VOLUME_NAME="gv0"
mkdir -p /data/$VOLUME_NAME
for i in $INTERNAL_IPS; do BRICKS+=" ${i}:/data/${VOLUME_NAME} "; done
gluster volume create $VOLUME_NAME replica 2 $BRICKS force
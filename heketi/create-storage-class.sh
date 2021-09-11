
# create heketi admin key secret
SECRET=$(echo $HEKETI_CLI_KEY | base64)
cat <<EOF > gluster-secret.yaml
apiVersion: v1
	kind: Secret
	metadata:
	  name: heketi-secret
	  namespace: default
	type: "kubernetes.io/glusterfs"
	data:
	  key: $HEKETI_CLI_KEY
EOF
kubectl create -f gluster-secret.yaml
kubectl get secret

# apiVersion: storage.k8s.io/v1
# kind: StorageClass
# metadata:
#   name: gluster
# provisioner: kubernetes.io/glusterfs
# parameters:
#   resturl: "$HEKETI_CLI_SERVER"
#   restuser: "$HEKETI_CLI_USER"
#   secretNamespace: "default"
#   secretName: "heketi-secret"
#   volumetype: "replicate:3"

# create gluster storage class
kubectl delete sc gluster
cat <<EOF > gluster-sc.yaml
apiVersion: storage.k8s.io/v1beta1
kind: StorageClass
metadata:
  name: gluster  
provisioner: kubernetes.io/glusterfs  
parameters:
  resturl: "$HEKETI_CLI_SERVER"
  restuser: "$HEKETI_CLI_USER"
  restuserkey: "$HEKETI_CLI_KEY"  
EOF
cat gluster-sc.yaml
kubectl apply -f gluster-sc.yaml
kubectl get storageclass

# create pvc
kubectl delete pvc gluster-pvc
cat <<EOF > gluster-pvc.yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
 name: gluster-pvc
 annotations:
   volume.beta.kubernetes.io/storage-class: gluster  
spec:
 accessModes:
  - ReadWriteOnce
 resources:
   requests:
     storage: 1Gi 
EOF
kubectl apply -f gluster-pvc.yaml
kubectl describe pvc gluster-pvc

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

# create gluster storage class
cat <<EOF > gluster-sc.yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: slow
provisioner: kubernetes.io/glusterfs
parameters:
  resturl: "$HEKETI_CLI_SERVER"
  restuser: "$HEKETI_CLI_USER"
  secretNamespace: "default"
  secretName: "heketi-secret"
  volumetype: "replicate:3"
EOF
kubectl apply -f gluster-sc.yaml
kubectl get storageclass


ACCOUNT_NAME=taquy

echo "
apiVersion: v1
kind: ServiceAccount
metadata:
  name: $ACCOUNT_NAME
---
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRoleBinding
metadata:
  name: cluster-admin-$ACCOUNT_NAME
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: $ACCOUNT_NAME
  namespace: default
" > sa.yml

kubectl create -f sa.yml

# get secret name of service account
SECRET_NAME=$(kubectl get sa $ACCOUNT_NAME -o jsonpath={.secrets[0].name})

kubectl describe secrets taquy 
SA_TOKEN=$(kubectl get secrets $SECRET_NAME -o jsonpath={.data.token} | base64 -d)
CA_CERT=$(kubectl config view --flatten --minify -o jsonpath={.clusters[0].cluster.certificate-authority-data})
CLUSTER_NAME=$(kubectl config view -o jsonpath="{.clusters[0].name}")

# get public ip of remote host (only on ec2 instance)
REMOTE_HOST=$(curl http://169.254.169.254/latest/meta-data/public-ipv4) && echo "$REMOTE_HOST"

# get public ip of remote host (any machine)
REMOTE_HOST=$(curl http://checkip.amazonaws.com) && echo "$REMOTE_HOST"

# create config file for client
echo "
apiVersion: v1
kind: Config
users:
- name: $ACCOUNT_NAME
  user:
    token: "${SA_TOKEN}"
clusters:
- cluster:
    certificate-authority-data: "${CA_CERT}"
    server: https://$REMOTE_HOST:6443
  name: $CLUSTER_NAME
contexts:
- context:
    cluster: $CLUSTER_NAME
    user: $ACCOUNT_NAME
  name: $CLUSTER_NAME
current-context: $CLUSTER_NAME
" > config.yml

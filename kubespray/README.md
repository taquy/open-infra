
# Setup ansible server kubernetes master node / install firewall
pre-installation/install-essential.sh

# Install kubernetes cluster
pre-installation/install-kubespray.sh

# Connect to cluster

## 1. Run gen-serviceaccount.sh in root
## 2. On client machine, copy SA secret and cluster config
```bash
scp -i ~/.ssh/taquy-vm root@$REMOTE_HOST:~/config.yml ~/.kube/config.yml
```
## 3. Set kubeconfig in env
export KUBECONFIG=~/.kube/config.yml

## 4. Verify cluster

```bash
# view config
kubectl cluster-info
kubectl config view

# select context
kubectl config get-contexts
kubectl config current-context
kubectl config use-context cluster.local
```

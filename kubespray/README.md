

# Connect to cluster

1. Run gen-serviceaccount.sh in root
2. On client machine, copy SA secret and cluster config
```bash
scp -i ~/.ssh/taquy-vm root@$REMOTE_HOST:~/config.yml ~/.kube/config.yml
```
3. Set kubeconfig in env
export KUBECONFIG=~/.kube/config.yml

4. Verify cluster


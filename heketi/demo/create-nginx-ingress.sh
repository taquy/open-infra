# https://docs.nginx.com/nginx-ingress-controller/installation/installation-with-helm/
git clone https://github.com/nginxinc/kubernetes-ingress/
cd kubernetes-ingress/deployments/helm-chart
git checkout v1.12.1

helm repo add nginx-stable https://helm.nginx.com/stable
helm repo update
helm install my-release nginx-stable/nginx-ingress
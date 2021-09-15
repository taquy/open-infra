# install nginx
apt install -y nginx
ufw allow 'Nginx HTTP'
systemctl enabled nginx
systemctl status nginx

# create config
mkdir -p /etc/nginx/
echo '
worker_processes  5;  ## Default: 1
worker_rlimit_nofile 8192;

events {
  worker_connections  4096;  ## Default: 1024
}
http {
    upstream backend {
        least_conn;
        server 10.0.2.62:6443;
        server 10.0.2.229:6443;
    }
    server {
        server_name k8s.taquy.com;
        location / {
            proxy_pass https://backend;
        }
    }
}
' > /etc/nginx/nginx.conf
cat /etc/nginx/nginx.conf
systemctl restart nginx
systemctl status nginx

curl https://k8s.taquy.dev

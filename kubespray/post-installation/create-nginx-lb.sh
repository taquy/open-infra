# install nginx
apt install -y nginx
ufw allow 'Nginx HTTP'
systemctl enabled nginx
systemctl status nginx

# create config
echo '
worker_processes  5;  ## Default: 1
worker_rlimit_nofile 8192;

events {
  worker_connections  4096;  ## Default: 1024
}
http {
    upstream backend {
        least_conn;
        server 10.0.2.62;
        server 10.0.2.229;
    }
    server {
        location / {
            proxy_pass http://backend;
        }
    }
}
' > /etc/nginx/nginx.conf
cat /etc/nginx/nginx.conf
systemctl restart nginx
systemctl status nginx

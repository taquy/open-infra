# install nginx
apt install -y nginx
ufw allow 'Nginx HTTP'
systemctl enabled nginx
systemctl status nginx

# create config
echo '
http {
    upstream backend {
        least_conn
        server 10.0.2.62;
        server 10.0.2.229;
    }
    server {
        location / {
            proxy_pass http://backend;
        }
    }
}
' >  /etc/nginx/nginx.conf

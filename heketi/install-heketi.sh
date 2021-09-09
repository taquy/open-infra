# install essentials
apt update
apt install -y software-properties-common
apt-add-repository --yes --update ppa:ansible/ansible
apt install -y ansible

# install heketi, heketi-cli
curl -s https://api.github.com/repos/heketi/heketi/releases/latest \
  | grep browser_download_url \
  | grep linux.amd64 \
  | cut -d '"' -f 4 \
  | wget -qi -
for i in `ls | grep heketi | grep .tar.gz`; do tar xvf $i; done
sudo cp heketi/{heketi,heketi-cli} /usr/local/bin
heketi --version
heketi-cli --version

# create heketi systemd unit
echo "
[Unit]
Description=Heketi Server

[Service]
Type=simple
WorkingDirectory=/var/lib/heketi
EnvironmentFile=-/etc/heketi/heketi.env
User=heketi
ExecStart=/usr/local/bin/heketi --config=/etc/heketi/heketi.json
Restart=on-failure
StandardOutput=syslog
StandardError=syslog

[Install]
WantedBy=multi-user.target
" > /etc/systemd/system/heketi.service

# run heketi daemon
wget -O /etc/heketi/heketi.env https://raw.githubusercontent.com/heketi/heketi/master/extras/systemd/heketi.env
chown -R heketi:heketi /var/lib/heketi /var/log/heketi /etc/heketi
setenforce 0
sed -i 's/^SELINUX=.*/SELINUX=permissive/g' /etc/selinux/config
systemctl daemon-reload
systemctl enable --now heketi
systemctl restart heketi
systemctl status heketi

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
HEKETI_PORT=8080

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
cat /etc/systemd/system/heketi.service

# set admin/user key
ADMIN_KEY="ZRl4d6Vtt5WCqgFB"
USER_KEY="VKT2ElSz86HN5Lep"

# create heketi user
groupadd --system heketi
useradd -s /sbin/nologin --system -g heketi heketi

# create heketi setting
mkdir -p /etc/heketi/
echo '
{
  "port": "'${HEKETI_PORT}'",
  "use_auth": true,
  "jwt": {
    "admin": {
      "key": "'${ADMIN_KEY}'"
    },
    "user": {
      "key": "'${USER_KEY}'"
    }
  },
  "glusterfs": {
    "executor": "ssh",
    "sshexec": {
      "keyfile": "/etc/heketi/taquy-vm",
      "user": "root",
      "fstab": "/etc/fstab"
    },
    "db": "/var/lib/heketi/heketi.db",
    "loglevel" : "debug"
  }
}
' > /etc/heketi/heketi.json
cat /etc/heketi/heketi.json

# share ssh key with heketi user
mkdir -p /var/lib/heketi /var/log/heketi /etc/heketi
cp /root/.ssh/taquy-vm /etc/heketi/
chown -R heketi:heketi /etc/heketi

# run heketi daemon
wget -O /etc/heketi/heketi.env https://raw.githubusercontent.com/heketi/heketi/master/extras/systemd/heketi.env
chown -R heketi:heketi /var/lib/heketi /var/log/heketi /etc/heketi
setenforce 0
sed -i 's/^SELINUX=.*/SELINUX=permissive/g' /etc/selinux/config
apt install -y selinux-utils
systemctl daemon-reload
systemctl enable --now heketi
systemctl restart heketi
systemctl status heketi

# store heketi cli configuration
HEKETI_HOST=$(hostname -I | cut -d' ' -f1)

echo '
export HEKETI_CLI_SERVER=http://'${HEKETI_HOST}':'${HEKETI_PORT}'
export HEKETI_CLI_USER=admin
export HEKETI_CLI_KEY="'${ADMIN_KEY}'"
' >> ~/.bashrc
source ~/.bashrc
cat ~/.bashrc

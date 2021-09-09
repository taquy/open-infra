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
cat<<EOF>/etc/systemd/system/heketi.service
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
EOF

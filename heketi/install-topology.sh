ADMIN_KEY="ZRl4d6Vtt5WCqgFB"
USER_KEY="VKT2ElSz86HN5Lep"

cat<<EOF>/etc/heketi/heketi.json  
{
  "port": "8080",
	"enable_tls": false,
	"cert_file": "",
	"key_file": "",
  "use_auth": true,
  "jwt": {
    "admin": {
      "key": "${ADMIN_KEY}"
    },
    "user": {
      "key": "${USER_KEY}"
    }
  },
  "backup_db_to_kube_secret": false,
  "profiling": false,
  "glusterfs": {
    "executor": "ssh",
    "sshexec": {
      "keyfile": "/etc/heketi/taquy-vm",
      "user": "root",
      "fstab": "/etc/fstab"
    },
    "db": "/var/lib/heketi/heketi.db",
    "refresh_time_monitor_gluster_nodes": 120,
    "start_time_monitor_gluster_nodes": 10,
    "loglevel" : "debug",
    "auto_create_block_hosting_volume": true,
    "block_hosting_volume_size": 10,
    "block_hosting_volume_options": "group gluster-block",
    "pre_request_volume_options": "",
    "post_request_volume_options": ""
  }
}
EOF




mkdir -p ~/projects/ansible/roles/heketi/{tasks,templates,defaults}
echo '
{
  "clusters": [
    {
      "nodes": [
      {% if gluster_servers is defined and gluster_servers is iterable %}
      {% for item in gluster_servers %}
        {
          "node": {
            "hostnames": {
              "manage": [
                "{{ item.servername }}"
              ],
              "storage": [
                "{{ item.serverip }}"
              ]
            },
            "zone": {{ item.zone }}
          },
          "devices": [
            "{{ item.disks | list | join ("\",\"") }}"
          ]
        }{% if not loop.last %},{% endif %}
    {% endfor %}
    {% endif %}
      ]
    }
  ]
}
' > projects/ansible/roles/heketi/templates/topology.json.j2


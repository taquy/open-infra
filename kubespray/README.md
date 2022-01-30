
# Setup ansible server kubernetes master node / install firewall
pre-installation/install-essential.sh

# Prepare ssh key
pre-installation/install-sshkey.sh

# Install kubernetes cluster
## On client machine
pre-installation/prepare-config.sh

## On remote machine
pre-installation/install-essential.sh
pre-installation/install-kubespray.sh

# Connect to cluster
## On cluster master machine
pre-installation/trust-host.sh

## On both client and master machine, please follow commented instruction within the script
pre-installation/connect-cluster.sh

# add repository
apt update -y && apt upgrade -y
apt install -y software-properties-common net-tools htop unzip git net-tools

# install apps
add-apt-repository ppa:deadsnakes/ppa
apt update -y
apt install build-essential zlib1g-dev libncurses5-dev libgdbm-dev \
  libnss3-dev libssl-dev libreadline-dev libffi-dev wget \
  python python3-pip -y
python --version

apt-add-repository ppa:ansible/ansible
apt install -y ansible

# install docker
apt-get remove docker docker-engine docker.io containerd runc

apt-get -y install \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

apt update -y
apt-get install docker-ce docker-ce-cli containerd.io

# post installation of docker
groupadd docker
usermod -aG docker $USER
newgrp docker 

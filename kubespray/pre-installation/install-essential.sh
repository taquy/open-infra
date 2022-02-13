
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

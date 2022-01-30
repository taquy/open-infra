
# add repository
apt update && apt upgrade -y
apt install -y software-properties-common net-tools htop unzip 
add-apt-repository ppa:deadsnakes/ppa
apt update

# install apps
apt install build-essential zlib1g-dev libncurses5-dev libgdbm-dev \
  libnss3-dev libssl-dev libreadline-dev libffi-dev wget \
  python python3-pip unzip htop git net-tools -y
python --version


apt-add-repository ppa:ansible/ansible

apt install -y ansible


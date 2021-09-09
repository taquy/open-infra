apt update && apt upgrade -y
apt install -y software-properties-common net-tools htop unzip 
add-apt-repository ppa:deadsnakes/ppa
apt update
apt install build-essential zlib1g-dev libncurses5-dev libgdbm-dev libnss3-dev libssl-dev libreadline-dev libffi-dev wget -y
apt install python python3-pip unzip htop -y
python --version
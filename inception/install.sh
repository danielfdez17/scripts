#!/bin/bash

echo "Updating package lists..."
sudo apt update && sudo apt upgrade -y

echo "Installing Vim"
sudo apt install vim -y

echo "Installing zsh..."
sudo apt install zsh -y
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
chsh -s $(which zsh)

echo "Installing Visual Studio Code..."
sudo snap install --classic code

echo "Installing Git..."
sudo apt install git -y

echo "Creating Git aliases..."
alias ga='git add'
alias gbr='git branch'
alias gc='git commit -m'
alias gl='git log --graph --oneline --decorate'
alias gls='git ls-files'
alias gm='git merge'
alias gp='git push'
alias gpr='git pull --rebase'
alias grep='grep --color=auto'
alias gss='git status -s'
alias gw='git worktree'

echo "Cloning Git repository..."
if [ ! -d "inception" ]; then
  rm -rf inception
  git clone https://github.com/danielfdez17/inception.git
fi

cd inception
git switch dev-alpine-2

echo "Installing Docker"
sudo apt update && sudo apt upgrade -y
sudo apt install -y ca-certificates curl gnupg
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSl https://download.docker.com/linux/ubuntu/gpg | sudo tee /etc/apt/keyrings/docker.asc > /dev/null
sudo chmod a+r /etc/apt/keyrings/docker.asc
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo systemctl start docker
sudo systemctl enable docker
docker --version
# sudo docker run hello-world (check if it is installed)
newgrp docker
sudo usermod -aG docker $USER # (to run docker without sudo)
docker ps
sudo systemctl enable docker

echo "Installing make"
sudo apt install make -y

echo "Installing docker-compose"
sudo apt install docker-compose -y

echo "Checking Python version"
python3 --version

echo "Installing Python pip"
sudo apt install python3-pip -y

echo "Installing distutils"
pip install distutils

sudo echo >> /etc/hosts
sudo echo "127.0.1.1  danfern3.42.fr" >> /etc/hosts

echo "Once the repo has been clone, run 'sudo chmod 777 -R .git/'"

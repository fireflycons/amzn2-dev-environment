#!/usr/bin/env bash

set -e
cd /tmp

# Local functions
function write_heading {

    local _heading_length=$((${#1} + 2))
    local _length=$(( $_heading_length > 40 ? $_heading_length : 40))

    echo ""
    yes "#" | head -$_length | paste -s -d '' -
    echo "# $1"
    yes "#" | head -$_length | paste -s -d '' -
    echo ""
}

###########################################################
#
# Base Configuration
#
###########################################################

# Update OS
write_heading "Updating OS"
sudo yum update -y
sudo yum upgrade -y

# Set up repos
sudo amazon-linux-extras enable python3.8
# Install basic toolset inc. docker, git, aws
sudo yum install wget nano docker telnet git tar aws-cli -y

# Set up user account and enable SSH
write_heading "Provisioning user '$LINUX_USERNAME'"
_home=/home/$LINUX_USERNAME
_ssh=$_home/.ssh
_authorized_keys=$_ssh/authorized_keys
sudo useradd $LINUX_USERNAME
echo "$LINUX_USERNAME:$LINUX_PASSWORD" | sudo chpasswd
sudo mkdir -p $_ssh
sudo mv /tmp/id_rsa.pub $_authorized_keys
sudo chown -R $LINUX_USERNAME:$LINUX_USERNAME $_ssh
sudo chmod 700 $_ssh
sudo chmod 600 $_authorized_keys
rm -f /tmp/id_rsa.pub
# Allow user to use docker
sudo usermod -a -G docker $LINUX_USERNAME
# OPTIONAL: Allow user to use sudo unrestricted
cat <<EOF > /tmp/user-$LINUX_USERNAME
# User rules for $LINUX_USERNAME
$LINUX_USERNAME ALL=(ALL) NOPASSWD: ALL
EOF
sudo chown root:root /tmp/user-$LINUX_USERNAME
sudo chmod 440 /tmp/user-$LINUX_USERNAME
sudo mv /tmp/user-$LINUX_USERNAME /etc/sudoers.d/

# Install Desktop, VNC and basic toolset
write_heading "Installing MATE Desktop"
sudo amazon-linux-extras install mate-desktop1.x epel -y
sudo yum install tigervnc-server chromium -y
# Enable docker
write_heading "Enabling docker service"
sudo systemctl enable docker
# Configure MATE
write_heading "Configuring MATE as desktop env"
sudo bash -c 'echo PREFERRED=/usr/bin/mate-session > /etc/sysconfig/desktop'
# Configure VNC to start for the user
write_heading "Configuring VNC server"
sudo cp /lib/systemd/system/vncserver@.service /etc/systemd/system/vncserver@.service
sudo sed -i "s/<USER>/$LINUX_USERNAME/" /etc/systemd/system/vncserver@.service
sudo systemctl daemon-reload
sudo systemctl enable vncserver@:1
# Set VNC access password
sudo mkdir -p $_home/.vnc
echo $VNC_PASSWORD | vncpasswd -f | sudo tee $_home/.vnc/passwd > /dev/null
sudo chown -R $LINUX_USERNAME:$LINUX_USERNAME $_home/.vnc
sudo chmod 600 $_home/.vnc/passwd
echo

###########################################################
#
# Development Tools
# Add in others or remove what you don't want
#
###########################################################

# VSCode
write_heading "Installing VSCode"
sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'
sudo yum install code -y

# Minikube and kubectl
write_heading "Installing Minikube"
curl -Lo minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 minikube /usr/local/bin/minikube
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
rm -f minikube
rm -f kubectl

write_heading "Installing Dev Languages"

# Golang - Manual install as yum often lags behind
_go_version=$(curl -L "https://golang.org/VERSION?m=text")
curl -Lo golang.tar.gz "https://go.dev/dl/go$_go_version.linux-amd64.tar.gz"
sudo tar -C /usr/lib -xzf golang.tar.gz
pushd /usr/bin
sudo ln -s /usr/lib/go/bin/go go
sudo ln -s /usr/lib/go/bin/gofmt gofmt
popd
rm -f golang.tar.gz

# Python 3
sudo yum install python38 -y
pushd /usr/bin
sudo ln -s ./python3.8 python3
sudo ln -s ./pip3.8 pip
popd

# C/C++/Make/AutoConf etc. and Python devel
sudo yum groupinstall "Development Tools" -y
#sudo yum install cmake python38-devel  -y

# Java
#wget --no-verbose --no-check-certificate -c --header "Cookie: oraclelicense=accept-securebackup-cookie" https://download.oracle.com/java/17/latest/jdk-17_linux-x64_bin.rpm
#sudo rpm -Uvh jdk-17_linux-x64_bin.rpm
#rm -f jdk-17_linux-x64_bin.rpm

# NodeJS
curl -sL https://rpm.nodesource.com/setup_16.x | sudo bash -
sudo yum install -y nodejs

# DotNet Core and PowerShell
#sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
#curl https://packages.microsoft.com/config/rhel/7/prod.repo | sudo tee /etc/yum.repos.d/microsoft.repo
#sudo yum install powershell dotnet-sdk-3.1 -y



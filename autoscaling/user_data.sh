#!/bin/bash
apt update
apt install docker.io -y
usermod -aG docker $USER
apt  install docker-compose -y
systemctl restart docker
systemctl enable docker
apt install awscli -y
chown root:docker /var/run/docker.sock
chown -R root:docker /var/run/docker
#!/bin/bash

# Install Docker
curl https://get.docker.com/ | sh

# Add the admin user to the docker group
# This allows the user to run docker commands without sudo
sudo usermod -aG docker ${admin_username}

# Start and enable Docker service
sudo systemctl start docker
sudo systemctl enable docker


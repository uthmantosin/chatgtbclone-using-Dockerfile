#!/bin/bash

# Exit on error
set -e

echo "Starting Docker installation..."

# Update package lists
echo "Updating package lists..."
sudo apt-get update -y

# Install prerequisite packages
echo "Installing prerequisite packages..."
sudo apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common

# Add Docker's GPG key
echo "Adding Docker's GPG key..."
if curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -; then
    echo "Docker GPG key added successfully."
else
    echo "Failed to add Docker GPG key. Exiting."
    exit 1
fi

# Verify the Docker GPG key
echo "Verifying the Docker GPG key..."
sudo apt-key fingerprint 0EBFCD88 || { echo "GPG key verification failed. Exiting."; exit 1; }

# Add Docker repository
echo "Adding Docker repository..."
sudo add-apt-repository \
    "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

# Update package lists again
echo "Updating package lists with the new Docker repository..."
sudo apt-get update -y

# Install Docker Engine, CLI, and containerd
echo "Installing Docker Engine, CLI, and containerd..."
sudo apt-get install -y docker-ce docker-ce-cli containerd.io

# Add the current user to the Docker group
echo "Adding the current user to the Docker group..."
sudo usermod -aG docker $USER

# Installation complete
echo "Docker installation complete!"

# Post-installation steps
echo "Please log out and back in or run 'newgrp docker' for Docker group changes to take effect."
echo "To verify Docker is installed correctly, run 'docker --version' and 'docker run hello-world'."

exit 0

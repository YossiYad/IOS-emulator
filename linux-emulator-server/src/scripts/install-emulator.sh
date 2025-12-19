#!/bin/bash

# Update package list and install necessary dependencies
sudo apt update
sudo apt install -y build-essential git curl

# Install Go programming language
if ! command -v go &> /dev/null
then
    echo "Go is not installed. Installing Go..."
    wget https://golang.org/dl/go1.20.5.linux-amd64.tar.gz
    sudo tar -C /usr/local -xzf go1.20.5.linux-amd64.tar.gz
    echo "export PATH=$PATH:/usr/local/go/bin" >> ~/.bashrc
    source ~/.bashrc
fi

# Install Node.js and npm
if ! command -v node &> /dev/null
then
    echo "Node.js is not installed. Installing Node.js..."
    curl -fsSL https://deb.nodesource.com/setup_16.x | sudo -E bash -
    sudo apt install -y nodejs
fi

# Install VNC server
if ! command -v vncserver &> /dev/null
then
    echo "VNC server is not installed. Installing VNC server..."
    sudo apt install -y tightvncserver
fi

# Install additional dependencies for the web UI
cd src/ui/web
npm install

echo "Installation completed successfully."
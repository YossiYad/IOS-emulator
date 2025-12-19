#!/bin/bash

# Update package list and install necessary packages for VNC
sudo apt update
sudo apt install -y xfce4 xfce4-goodies tightvncserver

# Set up VNC server configuration
VNC_CONFIG_DIR="$HOME/.vnc"
mkdir -p $VNC_CONFIG_DIR

# Create xstartup file for VNC
cat <<EOL > $VNC_CONFIG_DIR/xstartup
#!/bin/sh
xrdb $HOME/.Xresources
startxfce4 &
EOL

# Make xstartup executable
chmod +x $VNC_CONFIG_DIR/xstartup

# Start VNC server to create initial configuration
vncserver :1

# Kill the VNC server to apply new configuration
vncserver -kill :1

echo "VNC server setup complete. You can start it using 'vncserver :1'."
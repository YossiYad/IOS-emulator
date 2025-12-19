#!/bin/bash

# Start the VNC server
echo "Starting VNC server..."
bash ../setup-vnc.sh

# Start the emulator
echo "Starting the emulator..."
go run ../core/main.go

# Keep the script running to maintain the VNC session
while true; do
    sleep 60
done
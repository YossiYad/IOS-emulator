FROM ubuntu:24.04

# QEMU iOS Emulator - Production-ready Docker image
# Emulate iOS on any Linux server with QEMU and VNC display

LABEL maintainer="MarbleCeo"
LABEL description="QEMU iOS Emulator - Run iOS apps on Linux servers"
LABEL version="2.0.0"

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV QEMU_AUDIO_DRV=none

# Install QEMU, iOS emulation dependencies, and tools
RUN apt-get update && \
    apt-get install -y \
    qemu-system-arm \
    qemu-system-aarch64 \
    qemu-utils \
    build-essential \
    golang-go \
    npm \
    x11vnc \
    xvfb \
    openssh-server \
    net-tools \
    curl \
    wget \
    && apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Create directories
RUN mkdir -p /var/lib/silicon-emulator /usr/share/qemu/edk2-aarch64 /usr/share/qemu/ios-firmware

# Set the working directory
WORKDIR /app

# Copy the source code
COPY ./src /app/src
COPY ./Makefile /app/
COPY ./configs /app/configs

# Setup backend
WORKDIR /app
RUN go mod download 2>/dev/null || true

# Install frontend dependencies  
WORKDIR /app/src/ui/web
RUN npm install

# Setup VNC
RUN mkdir -p /root/.vnc && \
    echo "#!/bin/sh\nstartxvfb &\nexec vncserver -foreground -display :99" > /root/.vnc/xvfb-run.sh && \
    chmod +x /root/.vnc/xvfb-run.sh

# Expose ports
EXPOSE 5900 3000 2222 8080

# Copy VNC configuration
COPY ./configs/vnc/xstartup /root/.vnc/xstartup
RUN chmod +x /root/.vnc/xstartup

# Copy startup scripts
COPY ./src/scripts/start-emulator.sh /usr/local/bin/start-emulator
RUN chmod +x /usr/local/bin/start-emulator

# Command to run the emulator and VNC server
CMD ["sh", "-c", "start-emulator"]
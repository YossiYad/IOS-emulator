# Linux Emulator Server

Welcome to the Linux Emulator Server project! This application allows you to run a Linux emulator on a server and access it via a VNC client. This README provides an overview of the project, setup instructions, and usage guidelines.

## Features

- Run a Linux emulator in a server environment.
- Access the emulator through a VNC client for graphical interaction.
- Easy setup and configuration through scripts and Docker.

## Prerequisites

- A Linux server (Ubuntu 24.04.2 LTS recommended).
- Docker and Docker Compose installed.
- Basic knowledge of command line operations.

## Installation

1. **Clone the repository:**

   ```bash
   git clone <repository-url>
   cd linux-emulator-server
   ```

2. **Build the Docker image:**

   ```bash
   docker-compose build
   ```

3. **Run the setup scripts:**

   - Install the emulator dependencies:

     ```bash
     ./src/scripts/install-emulator.sh
     ```

   - Set up the VNC server:

     ```bash
     ./src/scripts/setup-vnc.sh
     ```

4. **Start the emulator and VNC server:**

   ```bash
   ./src/scripts/start-emulator.sh
   ```

## Usage

- After starting the emulator, you can connect to it using a VNC client. Use the server's IP address and the configured VNC port.
- Access the web UI by navigating to `http://<server-ip>:<web-port>` in your browser.

## Configuration

Configuration settings for the emulator and VNC server can be managed in the `src/core/config.go` file. You can load settings from environment variables or configuration files as needed.

## Contributing

Contributions are welcome! Please fork the repository and submit a pull request for any enhancements or bug fixes.

## License

This project is licensed under the MIT License. See the LICENSE file for more details.

## Acknowledgments

This project is a standalone effort to create a robust Linux emulator server. All contributions and improvements are appreciated as we continue to enhance its capabilities.
#!/bin/bash
# This script clones the ComfyUI-Easy-Install repository and runs the Linux installer.

# Exit immediately if a command exits with a non-zero status.
set -e

echo "Starting the ComfyUI Easy Install process..."

# 1. Clone the specific MAC-Linux branch from the repository
echo "Cloning the repository..."
git clone -b MAC-Linux https://github.com/Tavris1/ComfyUI-Easy-Install.git

# 2. Change directory into the newly cloned folder
# Note: We use 'ComfyUI-Easy-Install' (relative path)
# not '/ComfyUI-Easy-Install' (absolute path)
echo "Entering the repository directory..."
cd ComfyUI-Easy-Install

# 3. Make the Linux install script executable
echo "Setting permissions for the installer..."
chmod +x ComfyUI-Easy-Install-Linux.sh

# 4. Run the installer script
echo "Running the ComfyUI-Easy-Install-Linux.sh script..."
./ComfyUI-Easy-Install-Linux.sh

echo "Installation script has finished."

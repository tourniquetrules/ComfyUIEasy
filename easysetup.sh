#!/bin/bash
# This script clones the ComfyUI-Easy-Install repository and runs the Linux installer.
# Optional: Install SageAttention for enhanced performance

# Exit immediately if a command exits with a non-zero status.
set -e

echo "Starting the ComfyUI Easy Install process..."

# Check if user wants SageAttention
INSTALL_SAGE=false
if [[ "$1" == "--with-sage" ]]; then
    INSTALL_SAGE=true
    echo "Will also install SageAttention after ComfyUI setup"
elif [[ "$1" == "--help" || "$1" == "-h" ]]; then
    echo "Usage: $0 [--with-sage]"
    echo "  --with-sage    Also install SageAttention for enhanced performance"
    echo "  --help, -h     Show this help message"
    exit 0
fi

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

echo "ComfyUI installation script has finished."

# 5. Install SageAttention if requested
if [ "$INSTALL_SAGE" = true ]; then
    echo
    echo "Installing SageAttention..."
    
    # Copy SageAttention.sh to the correct directory
    if [ -f "FIXES/Linux/SageAttention.sh" ]; then
        echo "Copying SageAttention.sh to ComfyUI-Easy-Install directory..."
        cp FIXES/Linux/SageAttention.sh ComfyUI-Easy-Install/
        chmod +x ComfyUI-Easy-Install/SageAttention.sh
        
        # Change to the ComfyUI-Easy-Install subdirectory
        cd ComfyUI-Easy-Install
        
        # Run SageAttention installer (pass empty string to avoid interactive prompt)
        echo "Running SageAttention installer..."
        ./SageAttention.sh ""
        
        echo "SageAttention installation completed!"
        echo "You can now use run_nvidia_gpu_SageAttention.sh to start ComfyUI with SageAttention"
        
        # Go back to parent directory
        cd ..
    else
        echo "WARNING: SageAttention.sh not found in FIXES/Linux/"
        echo "SageAttention installation skipped"
    fi
fi

echo "Installation process completed!"

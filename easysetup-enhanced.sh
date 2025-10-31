#!/bin/bash
# Enhanced ComfyUI Easy Install with SageAttention support
# This script clones the ComfyUI-Easy-Install repository, installs ComfyUI, and optionally installs SageAttention

# Exit immediately if a command exits with a non-zero status.
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to show usage
show_usage() {
    echo "Enhanced ComfyUI Easy Install with SageAttention support"
    echo
    echo "Usage: $0 [options]"
    echo
    echo "Options:"
    echo "  --with-sage           Install SageAttention after ComfyUI setup"
    echo "  --sage-compile        Install SageAttention from source (latest version)"
    echo "  --help, -h            Show this help message"
    echo
    echo "Examples:"
    echo "  $0                    # Install ComfyUI only"
    echo "  $0 --with-sage        # Install ComfyUI + SageAttention (stable)"
    echo "  $0 --sage-compile     # Install ComfyUI + SageAttention (compile latest)"
    echo
}

# Parse command line arguments
INSTALL_SAGE=false
SAGE_COMPILE=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --with-sage)
            INSTALL_SAGE=true
            shift
            ;;
        --sage-compile)
            INSTALL_SAGE=true
            SAGE_COMPILE=true
            shift
            ;;
        --help|-h)
            show_usage
            exit 0
            ;;
        *)
            print_error "Unknown option: $1"
            show_usage
            exit 1
            ;;
    esac
done

print_status "Starting the Enhanced ComfyUI Easy Install process..."

if [ "$INSTALL_SAGE" = true ]; then
    if [ "$SAGE_COMPILE" = true ]; then
        print_status "Will install ComfyUI + SageAttention (compiled from source)"
    else
        print_status "Will install ComfyUI + SageAttention (stable version)"
    fi
else
    print_status "Will install ComfyUI only"
fi

echo

# 1. Clone the specific MAC-Linux branch from the repository
print_status "Cloning the ComfyUI-Easy-Install repository..."
if [ -d "ComfyUI-Easy-Install" ]; then
    print_warning "ComfyUI-Easy-Install directory already exists, removing it..."
    rm -rf ComfyUI-Easy-Install
fi

git clone -b MAC-Linux https://github.com/Tavris1/ComfyUI-Easy-Install.git

# 2. Change directory into the newly cloned folder
print_status "Entering the repository directory..."
cd ComfyUI-Easy-Install

# 3. Make the Linux install script executable
print_status "Setting permissions for the installer..."
chmod +x ComfyUI-Easy-Install-Linux.sh

# 4. Run the installer script
print_status "Running the ComfyUI-Easy-Install-Linux.sh script..."
./ComfyUI-Easy-Install-Linux.sh

print_success "ComfyUI installation completed!"

# 5. Install SageAttention if requested
if [ "$INSTALL_SAGE" = true ]; then
    echo
    print_status "Installing SageAttention..."
    
    # Copy SageAttention.sh to the correct directory
    if [ -f "FIXES/Linux/SageAttention.sh" ]; then
        print_status "Copying SageAttention.sh to ComfyUI-Easy-Install directory..."
        cp FIXES/Linux/SageAttention.sh ComfyUI-Easy-Install/
        chmod +x ComfyUI-Easy-Install/SageAttention.sh
        
        # Change to the ComfyUI-Easy-Install subdirectory
        cd ComfyUI-Easy-Install
        
        # Run SageAttention installer
        print_status "Running SageAttention installer..."
        if [ "$SAGE_COMPILE" = true ]; then
            ./SageAttention.sh --compile-source
        else
            ./SageAttention.sh
        fi
        
        print_success "SageAttention installation completed!"
        print_status "You can now use run_nvidia_gpu_SageAttention.sh to start ComfyUI with SageAttention"
        
        # Go back to parent directory
        cd ..
    else
        print_error "SageAttention.sh not found in FIXES/Linux/"
        print_warning "SageAttention installation skipped"
    fi
fi

echo
print_success "Installation process completed!"
echo
print_status "Available scripts in ComfyUI-Easy-Install/ComfyUI-Easy-Install/:"
if [ -f "ComfyUI-Easy-Install/run_comfyui.sh" ]; then
    echo "  - ./run_comfyui.sh                    # Start ComfyUI normally"
fi
if [ -f "ComfyUI-Easy-Install/run_nvidia_gpu.sh" ]; then
    echo "  - ./run_nvidia_gpu.sh                 # Start ComfyUI with NVIDIA GPU support"
fi
if [ "$INSTALL_SAGE" = true ] && [ -f "ComfyUI-Easy-Install/run_nvidia_gpu_SageAttention.sh" ]; then
    echo "  - ./run_nvidia_gpu_SageAttention.sh   # Start ComfyUI with SageAttention"
fi
echo
print_status "To start ComfyUI, run:"
echo "  cd ComfyUI-Easy-Install/ComfyUI-Easy-Install"
if [ "$INSTALL_SAGE" = true ]; then
    echo "  ./run_nvidia_gpu_SageAttention.sh"
else
    echo "  ./run_comfyui.sh"
fi
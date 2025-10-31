#!/bin/bash
# Standalone SageAttention installer for existing ComfyUI installations
# This script can be run after ComfyUI is already installed to add SageAttention support

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
    echo "SageAttention installer for ComfyUI Easy Install"
    echo
    echo "Usage: $0 [options]"
    echo
    echo "Options:"
    echo "  --compile-source      Install latest version compiled from source"
    echo "  --help, -h           Show this help message"
    echo
    echo "Examples:"
    echo "  $0                   # Install stable version from PyPI (recommended)"
    echo "  $0 --compile-source  # Compile latest version from source (advanced)"
    echo
    echo "Note: This script should be run from the directory containing ComfyUI-Easy-Install"
}

# Parse command line arguments
COMPILE_SOURCE=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --compile-source)
            COMPILE_SOURCE=true
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

print_status "SageAttention installer for ComfyUI Easy Install"
echo

# Check if ComfyUI-Easy-Install directory exists
if [ ! -d "ComfyUI-Easy-Install" ]; then
    print_error "ComfyUI-Easy-Install directory not found!"
    print_status "Please run this script from the directory containing ComfyUI-Easy-Install"
    print_status "Or run the enhanced easysetup script first to install ComfyUI"
    exit 1
fi

# Check if SageAttention.sh exists in FIXES/Linux
if [ ! -f "ComfyUI-Easy-Install/FIXES/Linux/SageAttention.sh" ]; then
    print_error "SageAttention.sh not found in ComfyUI-Easy-Install/FIXES/Linux/"
    print_status "Please ensure you have the complete ComfyUI-Easy-Install repository"
    exit 1
fi

# Check if ComfyUI-Easy-Install subdirectory exists
if [ ! -d "ComfyUI-Easy-Install/ComfyUI-Easy-Install" ]; then
    print_error "ComfyUI installation directory not found!"
    print_status "Please run the ComfyUI installer first"
    exit 1
fi

print_status "Found ComfyUI installation"

# Copy SageAttention.sh to the correct directory
print_status "Copying SageAttention.sh to the correct location..."
cp ComfyUI-Easy-Install/FIXES/Linux/SageAttention.sh ComfyUI-Easy-Install/ComfyUI-Easy-Install/
chmod +x ComfyUI-Easy-Install/ComfyUI-Easy-Install/SageAttention.sh

# Change to the ComfyUI-Easy-Install subdirectory
cd ComfyUI-Easy-Install/ComfyUI-Easy-Install

# Run SageAttention installer
print_status "Running SageAttention installer..."
if [ "$COMPILE_SOURCE" = true ]; then
    print_warning "Compiling from source - this may take several minutes..."
    ./SageAttention.sh --compile-source ""
else
    print_status "Installing stable version from PyPI..."
    ./SageAttention.sh ""
fi

print_success "SageAttention installation completed!"
echo
print_status "You can now start ComfyUI with SageAttention using:"
print_status "  cd ComfyUI-Easy-Install/ComfyUI-Easy-Install"
print_status "  ./run_nvidia_gpu_SageAttention.sh"
echo
print_status "Available startup scripts:"
echo "  - ./run_comfyui.sh                    # Start ComfyUI normally"
echo "  - ./run_nvidia_gpu.sh                 # Start ComfyUI with NVIDIA GPU support"  
echo "  - ./run_nvidia_gpu_SageAttention.sh   # Start ComfyUI with SageAttention"
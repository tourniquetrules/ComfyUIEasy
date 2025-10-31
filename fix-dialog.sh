#!/bin/bash
# Emergency fix for stuck needrestart dialog
# Run this if you're currently stuck in the daemon restart dialog

echo "Emergency Fix: Handling stuck needrestart dialog..."

# Method 1: Try to send Enter key to current dialog
echo "Attempting to dismiss dialog..."
echo -e "\n" | sudo tee /proc/$(pgrep -f needrestart)/fd/0 2>/dev/null || true

# Method 2: Kill the needrestart process
echo "Killing needrestart processes..."
sudo pkill -f needrestart 2>/dev/null || true

# Method 3: Configure system to avoid future dialogs
echo "Configuring system to prevent future dialogs..."
export DEBIAN_FRONTEND=noninteractive
export NEEDRESTART_MODE=a

# Create/update needrestart config
sudo mkdir -p /etc/needrestart
echo '$nrconf{restart} = "a";' | sudo tee /etc/needrestart/needrestart.conf

# Set apt configuration
echo 'DPkg::Post-Invoke { "if [ -x /usr/bin/needrestart ]; then /usr/bin/needrestart -r a; fi"; };' | sudo tee /etc/apt/apt.conf.d/99needrestart

echo "Fix applied! Try running your installation again."
echo ""
echo "If still stuck, you can:"
echo "1. Press Ctrl+C to cancel current operation"
echo "2. Use the non-interactive installer: ./easysetup-noninteractive.sh --with-sage"
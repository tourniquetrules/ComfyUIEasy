# ComfyUIEasy - One-Script ComfyUI Setup with Cloudflare Tunnel

🚀 **The easiest way to get ComfyUI running with secure internet access in minutes!**

This repository provides a complete solution for:
1. **Installing ComfyUI** on Linux/Lambda.ai instances
2. **Exposing it securely** to the internet via Cloudflare tunnels
3. **Managing the setup** with simple commands

## 🎯 Quick Start Options

### Option 1: Basic ComfyUI (2 Commands!)
```bash
# 1. Download and run ComfyUI installer
curl -sSL https://raw.githubusercontent.com/tourniquetrules/ComfyUIEasy/main/easysetup.sh | bash

# 2. Set up secure internet access
export CLOUDFLARE_DOMAIN=your-subdomain.yourdomain.com
./cloudflare-tunnel-setup.sh
```

### Option 2: ComfyUI + SageAttention (Enhanced Performance!)
```bash
# 1. Install ComfyUI with SageAttention in one command
curl -sSL https://raw.githubusercontent.com/tourniquetrules/ComfyUIEasy/main/easysetup.sh | bash -s -- --with-sage

# 2. Set up secure internet access
export CLOUDFLARE_DOMAIN=your-subdomain.yourdomain.com
./cloudflare-tunnel-setup.sh
```

### Option 3: Enhanced Installer (Full Control)
```bash
# Download the enhanced installer
curl -O https://raw.githubusercontent.com/tourniquetrules/ComfyUIEasy/main/easysetup-enhanced.sh
chmod +x easysetup-enhanced.sh

# Choose your installation:
./easysetup-enhanced.sh                    # ComfyUI only
./easysetup-enhanced.sh --with-sage        # ComfyUI + SageAttention (stable)
./easysetup-enhanced.sh --sage-compile     # ComfyUI + SageAttention (latest)
```

**Result:** Your ComfyUI will be accessible at `https://your-subdomain.yourdomain.com`

## 📋 What This Does

### Step 1: ComfyUI Installation (`easysetup.sh`)
- Downloads the latest ComfyUI-Easy-Install from Tavris1's repository
- Installs ComfyUI with all dependencies on Linux
- Sets up the environment properly for Lambda.ai and other cloud instances

### Step 2: Cloudflare Tunnel Setup
- Installs Cloudflare daemon (`cloudflared`)
- Creates a secure tunnel to expose ComfyUI (port 8188) to the internet
- Sets up automatic startup and management
- Provides HTTPS access with Cloudflare's security and performance benefits

## 🛠 Prerequisites

- **Linux server** (Lambda.ai, AWS, GCP, home server, etc.)
- **Cloudflare account** with a domain you own
- **Sudo access** on the server

## 📁 Repository Contents

```
├── easysetup.sh                  # Basic ComfyUI installer (supports --with-sage)
├── easysetup-enhanced.sh         # Enhanced installer with full SageAttention options
├── install-sageattention.sh      # Standalone SageAttention installer
├── cloudflare-tunnel-setup.sh    # Tunnel setup script  
├── tunnel-manager.sh             # Daily management commands
└── README.md                     # This documentation
```

## ⚡ SageAttention Support

**SageAttention** provides significant performance improvements for attention mechanisms in ComfyUI, especially beneficial for:
- Large model inference
- High-resolution image generation  
- Batch processing
- Memory-constrained environments

### SageAttention Installation Options:

1. **During initial setup**: Use `--with-sage` flag with any installer
2. **After ComfyUI is installed**: Run the standalone installer
3. **Latest version**: Use `--sage-compile` for cutting-edge features

```bash
# Add SageAttention to existing ComfyUI installation
curl -O https://raw.githubusercontent.com/tourniquetrules/ComfyUIEasy/main/install-sageattention.sh
chmod +x install-sageattention.sh
./install-sageattention.sh                 # Stable version
./install-sageattention.sh --compile-source # Latest version
```

## 🔧 Detailed Setup

### Option 1: Quick Setup (Recommended)
```bash
# Download this repository
git clone https://github.com/tourniquetrules/ComfyUIEasy.git
cd ComfyUIEasy

# Install ComfyUI
./easysetup.sh

# Set up tunnel (replace with your domain)
export CLOUDFLARE_DOMAIN=comfy.yourdomain.com
./cloudflare-tunnel-setup.sh
```

### Option 2: Step by Step
```bash
# 1. Install ComfyUI
curl -sSL https://raw.githubusercontent.com/tourniquetrules/ComfyUIEasy/main/easysetup.sh | bash

# 2. Download tunnel scripts
curl -O https://raw.githubusercontent.com/tourniquetrules/ComfyUIEasy/main/cloudflare-tunnel-setup.sh
curl -O https://raw.githubusercontent.com/tourniquetrules/ComfyUIEasy/main/tunnel-manager.sh
chmod +x *.sh

# 3. Configure and run tunnel
export CLOUDFLARE_DOMAIN=your-subdomain.yourdomain.com
./cloudflare-tunnel-setup.sh
```

## 🌍 Use Cases

### Lambda.ai GPU Instances
Perfect for exposing your Lambda.ai ComfyUI instance to the internet without dealing with networking complexities.

### Home Servers  
Run ComfyUI on your local machine and access it from anywhere securely.

### Development/Testing
Quick setup for testing ComfyUI workflows and sharing with others.

### Production Deployments
Secure, scalable access to ComfyUI with Cloudflare's global network.

## 🎛 Managing Your Setup

### Daily Commands
```bash
# Check if everything is running
./tunnel-manager.sh status

# View logs if there are issues  
./tunnel-manager.sh logs

# Restart tunnel if needed
./tunnel-manager.sh restart

# Test connectivity
./tunnel-manager.sh test
```

### ComfyUI Commands (after installation)
```bash
# Navigate to ComfyUI directory
cd ComfyUI-Easy-Install/ComfyUI-Easy-Install

# Start ComfyUI (choose based on your setup)
./run_comfyui.sh                    # Basic ComfyUI
./run_nvidia_gpu.sh                 # With NVIDIA GPU support
./run_nvidia_gpu_SageAttention.sh   # With SageAttention (if installed)

# Update ComfyUI
./update_comfy_and_run.sh
```

## 🔐 Security Features

- **No port forwarding** required - tunnel creates outbound connection
- **Automatic HTTPS** - Cloudflare handles SSL certificates  
- **DDoS protection** - Built-in Cloudflare security
- **IP independence** - Works regardless of changing server IPs
- **Private credentials** - Tunnel credentials stored locally, never in repo

## ❓ Troubleshooting

### ComfyUI Won't Start
```bash
# Check if ComfyUI is running
ss -tlnp | grep 8188

# If not running, start it
cd ComfyUI-Easy-Install
./run_comfyui.sh
```

### Tunnel Connection Issues  
```bash
# Check tunnel status
./tunnel-manager.sh status

# View detailed logs
./tunnel-manager.sh logs

# Test connection
./tunnel-manager.sh test
```

### Domain Not Resolving
- DNS changes can take up to 48 hours
- Check Cloudflare dashboard for DNS records
- Ensure your domain is managed by Cloudflare

## 🤝 Contributing

This repository combines:
- [ComfyUI-Easy-Install](https://github.com/Tavris1/ComfyUI-Easy-Install) by Tavris1
- Custom Cloudflare tunnel automation

Feel free to submit issues or improvements!

## 🔗 Related Projects

- **ComfyUI**: https://github.com/comfyanonymous/ComfyUI
- **ComfyUI-Easy-Install**: https://github.com/Tavris1/ComfyUI-Easy-Install  
- **Cloudflare Tunnels**: https://developers.cloudflare.com/cloudflare-one/connections/connect-networks/
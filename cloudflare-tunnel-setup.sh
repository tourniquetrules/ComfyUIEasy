#!/bin/bash

# Cloudflare Tunnel Setup Script
# Generic version safe for public repositories
# This script automates the installation and configuration of Cloudflare tunnels
# for any Linux server running web services

set -e  # Exit on any error

# Configuration variables - UPDATE THESE FOR YOUR SETUP
DOMAIN="${CLOUDFLARE_DOMAIN:-your-subdomain.yourdomain.com}"  # Set via environment variable or update here
LOCAL_PORT="${SERVICE_PORT:-8188}"          # Port where your service is running
TUNNEL_NAME="${TUNNEL_NAME:-my-tunnel}"     # Name for your tunnel
SERVICE_URL="http://localhost:${LOCAL_PORT}"

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

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to validate configuration
validate_config() {
    if [ "$DOMAIN" = "your-subdomain.yourdomain.com" ]; then
        print_error "Please update the DOMAIN variable or set CLOUDFLARE_DOMAIN environment variable"
        echo "Example: export CLOUDFLARE_DOMAIN=myapp.mydomain.com"
        exit 1
    fi
    
    if [ "$TUNNEL_NAME" = "my-tunnel" ]; then
        print_warning "Using default tunnel name. Consider setting TUNNEL_NAME environment variable"
    fi
}

# Function to check if service is running on specified port
check_service_port() {
    if ss -tlnp | grep -q ":${LOCAL_PORT}"; then
        print_success "Service detected running on port ${LOCAL_PORT}"
        return 0
    else
        print_warning "No service detected on port ${LOCAL_PORT}"
        print_warning "Make sure your application is running before proceeding"
        read -p "Continue anyway? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi
}

# Step 1: Install cloudflared
install_cloudflared() {
    print_status "Step 1: Installing Cloudflare daemon (cloudflared)..."
    
    if command_exists cloudflared; then
        print_warning "cloudflared is already installed"
        cloudflared --version
        read -p "Do you want to reinstall? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            return 0
        fi
    fi
    
    print_status "Downloading cloudflared binary..."
    curl -L https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 -o cloudflared
    
    print_status "Making binary executable and moving to system path..."
    chmod +x cloudflared
    sudo mv cloudflared /usr/local/bin/
    
    print_success "cloudflared installed successfully"
    cloudflared --version
}

# Step 2: Authenticate with Cloudflare
authenticate_cloudflare() {
    print_status "Step 2: Authenticating with Cloudflare..."
    
    if [ -f "$HOME/.cloudflared/cert.pem" ]; then
        print_warning "Cloudflare credentials already exist"
        read -p "Do you want to re-authenticate? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            return 0
        fi
    fi
    
    print_status "Opening browser for Cloudflare authentication..."
    print_status "Please complete the login process in your browser"
    cloudflared tunnel login
    
    if [ -f "$HOME/.cloudflared/cert.pem" ]; then
        print_success "Authentication successful"
    else
        print_error "Authentication failed"
        exit 1
    fi
}

# Step 3: Create tunnel
create_tunnel() {
    print_status "Step 3: Creating Cloudflare tunnel..."
    
    # Check if tunnel already exists
    if cloudflared tunnel list | grep -q "$TUNNEL_NAME"; then
        print_warning "Tunnel '$TUNNEL_NAME' already exists"
        TUNNEL_ID=$(cloudflared tunnel list | grep "$TUNNEL_NAME" | awk '{print $1}')
        print_status "Using existing tunnel ID: $TUNNEL_ID"
    else
        print_status "Creating new tunnel: $TUNNEL_NAME"
        cloudflared tunnel create "$TUNNEL_NAME"
        TUNNEL_ID=$(cloudflared tunnel list | grep "$TUNNEL_NAME" | awk '{print $1}')
        print_success "Tunnel created with ID: $TUNNEL_ID"
    fi
    
    # Export tunnel ID for use in other functions
    export TUNNEL_ID
}

# Step 4: Create DNS record
create_dns_record() {
    print_status "Step 4: Creating DNS record for $DOMAIN..."
    
    print_status "Creating CNAME record: $DOMAIN -> $TUNNEL_ID"
    if cloudflared tunnel route dns "$TUNNEL_ID" "$DOMAIN"; then
        print_success "DNS record created successfully"
    else
        print_error "Failed to create DNS record"
        print_warning "You may need to create this manually in Cloudflare dashboard"
    fi
}

# Step 5: Create configuration file
create_config() {
    print_status "Step 5: Creating tunnel configuration..."
    
    mkdir -p "$HOME/.cloudflared"
    
    cat > "$HOME/.cloudflared/config.yml" << EOF
tunnel: $TUNNEL_ID
credentials-file: $HOME/.cloudflared/$TUNNEL_ID.json

ingress:
  - hostname: $DOMAIN
    service: $SERVICE_URL
  - service: http_status:404
EOF
    
    print_success "Configuration file created at $HOME/.cloudflared/config.yml"
    
    # Validate configuration
    print_status "Validating tunnel configuration..."
    if cloudflared tunnel --config "$HOME/.cloudflared/config.yml" ingress validate; then
        print_success "Configuration is valid"
    else
        print_error "Configuration validation failed"
        exit 1
    fi
}

# Step 6: Create systemd service
create_systemd_service() {
    print_status "Step 6: Creating systemd service for auto-start..."
    
    cat > /tmp/cloudflared-tunnel.service << EOF
[Unit]
Description=Cloudflare Tunnel
After=network.target

[Service]
Type=simple
User=$USER
ExecStart=/usr/local/bin/cloudflared tunnel --config $HOME/.cloudflared/config.yml run
Restart=on-failure
RestartSec=5s
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
EOF
    
    sudo cp /tmp/cloudflared-tunnel.service /etc/systemd/system/
    sudo systemctl daemon-reload
    sudo systemctl enable cloudflared-tunnel.service
    
    print_success "Systemd service created and enabled"
}

# Step 7: Start tunnel and test
start_and_test_tunnel() {
    print_status "Step 7: Starting tunnel and testing connection..."
    
    # Kill any existing tunnel processes
    pkill -f cloudflared || true
    sleep 2
    
    # Start tunnel in background
    print_status "Starting tunnel..."
    cloudflared tunnel --config "$HOME/.cloudflared/config.yml" run &
    TUNNEL_PID=$!
    
    # Wait for tunnel to establish connections
    print_status "Waiting for tunnel to establish connections..."
    sleep 10
    
    # Test connection
    print_status "Testing connection to https://$DOMAIN..."
    if curl -s -I "https://$DOMAIN" | grep -q "HTTP/"; then
        print_success "Tunnel is working! Your service is accessible at: https://$DOMAIN"
    else
        print_error "Connection test failed"
        print_warning "Check if your local service is running on port $LOCAL_PORT"
    fi
    
    # Start systemd service instead of background process
    print_status "Starting systemd service..."
    kill $TUNNEL_PID 2>/dev/null || true
    sleep 2
    sudo systemctl start cloudflared-tunnel.service
    
    if sudo systemctl is-active --quiet cloudflared-tunnel.service; then
        print_success "Systemd service is running"
    else
        print_error "Failed to start systemd service"
        exit 1
    fi
}

# Function to show usage
show_usage() {
    echo "Cloudflare Tunnel Setup Script"
    echo
    echo "Usage: $0 [options]"
    echo
    echo "Environment Variables:"
    echo "  CLOUDFLARE_DOMAIN  - Your domain/subdomain (required)"
    echo "  SERVICE_PORT       - Port your service runs on (default: 8188)"
    echo "  TUNNEL_NAME        - Name for your tunnel (default: my-tunnel)"
    echo
    echo "Examples:"
    echo "  CLOUDFLARE_DOMAIN=api.example.com SERVICE_PORT=3000 $0"
    echo "  export CLOUDFLARE_DOMAIN=myapp.mydomain.com && $0"
    echo
    echo "Options:"
    echo "  -h, --help         Show this help message"
    echo
}

# Main execution
main() {
    # Handle command line arguments
    case "${1:-}" in
        -h|--help)
            show_usage
            exit 0
            ;;
    esac
    
    echo -e "${BLUE}================================${NC}"
    echo -e "${BLUE} Cloudflare Tunnel Setup Script${NC}"
    echo -e "${BLUE}================================${NC}"
    echo
    
    # Validate configuration
    validate_config
    
    echo "This script will set up a Cloudflare tunnel for:"
    echo "  Domain: $DOMAIN"
    echo "  Local service: $SERVICE_URL"
    echo "  Tunnel name: $TUNNEL_NAME"
    echo
    
    # Check if running as root
    if [ "$EUID" -eq 0 ]; then
        print_error "Please do not run this script as root"
        exit 1
    fi
    
    # Check prerequisites
    print_status "Checking prerequisites..."
    
    if ! command_exists curl; then
        print_error "curl is required but not installed"
        exit 1
    fi
    
    if ! command_exists sudo; then
        print_error "sudo is required but not available"
        exit 1
    fi
    
    # Check if service is running on target port
    check_service_port
    
    # Confirm before proceeding
    echo
    read -p "Do you want to proceed with the setup? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_status "Setup cancelled"
        exit 0
    fi
    
    # Execute setup steps
    install_cloudflared
    authenticate_cloudflare
    create_tunnel
    create_dns_record
    create_config
    create_systemd_service
    start_and_test_tunnel
    
    echo
    echo -e "${GREEN}================================${NC}"
    echo -e "${GREEN}     Setup Complete!${NC}"
    echo -e "${GREEN}================================${NC}"
    echo
    echo "Your service is now accessible at: https://$DOMAIN"
    echo
    echo "Useful commands:"
    echo "  Check tunnel status: sudo systemctl status cloudflared-tunnel"
    echo "  View tunnel logs:    sudo journalctl -u cloudflared-tunnel -f"
    echo "  Restart tunnel:      sudo systemctl restart cloudflared-tunnel"
    echo "  Stop tunnel:         sudo systemctl stop cloudflared-tunnel"
    echo "  List tunnels:        cloudflared tunnel list"
    echo
    echo "Configuration files:"
    echo "  Tunnel config:       $HOME/.cloudflared/config.yml"
    echo "  Credentials:         $HOME/.cloudflared/$TUNNEL_ID.json"
    echo "  Systemd service:     /etc/systemd/system/cloudflared-tunnel.service"
    echo
    print_warning "Keep your credentials file secure and do not commit it to version control!"
}

# Run main function
main "$@"
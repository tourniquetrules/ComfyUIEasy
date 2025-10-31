#!/bin/bash

# Cloudflare Tunnel Management Script
# Simple script to manage tunnel operations

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
show_help() {
    echo "Cloudflare Tunnel Management Script"
    echo
    echo "Usage: $0 [command]"
    echo
    echo "Commands:"
    echo "  status      - Show tunnel service status"
    echo "  logs        - Show real-time tunnel logs"
    echo "  start       - Start the tunnel service"
    echo "  stop        - Stop the tunnel service"
    echo "  restart     - Restart the tunnel service"
    echo "  test        - Test tunnel connection"
    echo "  list        - List all tunnels"
    echo "  info        - Show tunnel configuration"
    echo "  cleanup     - Remove old tunnel processes"
    echo "  help        - Show this help message"
    echo
}

# Function to check if service exists
check_service() {
    if ! systemctl list-unit-files | grep -q cloudflared-tunnel.service; then
        print_error "Cloudflared tunnel service not found"
        print_warning "Please run the setup script first"
        exit 1
    fi
}

# Function to show service status
show_status() {
    check_service
    print_status "Checking tunnel service status..."
    sudo systemctl status cloudflared-tunnel.service --no-pager
}

# Function to show logs
show_logs() {
    check_service
    print_status "Showing real-time tunnel logs (Ctrl+C to exit)..."
    sudo journalctl -u cloudflared-tunnel.service -f --no-pager
}

# Function to start service
start_service() {
    check_service
    print_status "Starting tunnel service..."
    if sudo systemctl start cloudflared-tunnel.service; then
        print_success "Tunnel service started"
        sleep 2
        show_status
    else
        print_error "Failed to start tunnel service"
        exit 1
    fi
}

# Function to stop service
stop_service() {
    check_service
    print_status "Stopping tunnel service..."
    if sudo systemctl stop cloudflared-tunnel.service; then
        print_success "Tunnel service stopped"
    else
        print_error "Failed to stop tunnel service"
        exit 1
    fi
}

# Function to restart service
restart_service() {
    check_service
    print_status "Restarting tunnel service..."
    if sudo systemctl restart cloudflared-tunnel.service; then
        print_success "Tunnel service restarted"
        sleep 2
        show_status
    else
        print_error "Failed to restart tunnel service"
        exit 1
    fi
}

# Function to test connection
test_connection() {
    if [ ! -f "$HOME/.cloudflared/config.yml" ]; then
        print_error "Tunnel configuration not found"
        print_warning "Please run the setup script first"
        exit 1
    fi
    
    # Extract domain from config
    DOMAIN=$(grep "hostname:" "$HOME/.cloudflared/config.yml" | awk '{print $3}')
    
    if [ -z "$DOMAIN" ]; then
        print_error "Could not find domain in configuration"
        exit 1
    fi
    
    print_status "Testing connection to https://$DOMAIN..."
    
    if curl -s -I "https://$DOMAIN" | head -1; then
        print_success "Tunnel is working! Service accessible at: https://$DOMAIN"
    else
        print_error "Connection test failed"
        print_warning "Check if tunnel service is running: $0 status"
    fi
}

# Function to list tunnels
list_tunnels() {
    if ! command -v cloudflared >/dev/null 2>&1; then
        print_error "cloudflared not installed"
        exit 1
    fi
    
    print_status "Listing all tunnels..."
    cloudflared tunnel list
}

# Function to show tunnel info
show_info() {
    if [ ! -f "$HOME/.cloudflared/config.yml" ]; then
        print_error "Tunnel configuration not found"
        exit 1
    fi
    
    print_status "Tunnel Configuration:"
    echo "===================="
    cat "$HOME/.cloudflared/config.yml"
    echo "===================="
    echo
    
    TUNNEL_ID=$(grep "tunnel:" "$HOME/.cloudflared/config.yml" | awk '{print $2}')
    if [ -n "$TUNNEL_ID" ]; then
        print_status "Tunnel Details:"
        cloudflared tunnel info "$TUNNEL_ID" 2>/dev/null || print_warning "Could not fetch tunnel details"
    fi
}

# Function to cleanup old processes
cleanup_processes() {
    print_status "Cleaning up old cloudflared processes..."
    
    # Kill any running cloudflared processes
    if pgrep -f cloudflared > /dev/null; then
        print_warning "Found running cloudflared processes, stopping them..."
        sudo pkill -f cloudflared
        sleep 2
        print_success "Old processes cleaned up"
    else
        print_success "No old processes found"
    fi
}

# Main function
main() {
    case "${1:-help}" in
        status|stat)
            show_status
            ;;
        logs|log)
            show_logs
            ;;
        start)
            start_service
            ;;
        stop)
            stop_service
            ;;
        restart)
            restart_service
            ;;
        test)
            test_connection
            ;;
        list)
            list_tunnels
            ;;
        info)
            show_info
            ;;
        cleanup|clean)
            cleanup_processes
            ;;
        help|--help|-h)
            show_help
            ;;
        *)
            print_error "Unknown command: $1"
            echo
            show_help
            exit 1
            ;;
    esac
}

# Run main function
main "$@"
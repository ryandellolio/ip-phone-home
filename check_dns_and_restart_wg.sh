#!/bin/bash

# Configuration
DNS_ENTRY="edge.delloliocdn.com"
WG_INTERFACE="wg0"
LOG_FILE="/var/log/dns_check.log"
IP_FILE="/var/log/last_ip.log"

# Function to log with timestamp
log_with_date() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

# Function to log WireGuard status with indentation and timestamp
log_wg_status() {
    while read -r line; do
        echo "$(date '+%Y-%m-%d %H:%M:%S') -     $line" >> "$LOG_FILE"
    done
}

# Get the current IP address of the DNS entry
current_ip=$(dig +short "$DNS_ENTRY")
log_with_date "Debug: Retrieved IP from DNS is '$current_ip'"

# If dig command fails or returns empty, log and exit
if [ -z "$current_ip" ]; then
    log_with_date "Failed to resolve DNS or received empty IP. No changes made."
    exit 1
fi

# Log the current IP with timestamp
log_with_date "CURRENT IP: $current_ip"

# Read the last known IP address
if [ -f "$IP_FILE" ]; then
    last_ip=$(cat "$IP_FILE")
    log_with_date "Debug: Last known IP is '$last_ip'"
else
    last_ip=""
    echo "$current_ip" > "$IP_FILE"
fi

# Compare the current IP with the last known IP
if [ "$current_ip" != "$last_ip" ]; then
    # Log the change
    log_with_date "IP has changed from $last_ip to $current_ip"
    
    # Update the last known IP
    echo "$current_ip" > "$IP_FILE"

    # Shut down the WireGuard interface
    log_with_date "Shutting down $WG_INTERFACE due to IP change..."
    if wg-quick down "$WG_INTERFACE"; then
        log_with_date "$WG_INTERFACE successfully shut down."
    else
        log_with_date "Failed to shut down $WG_INTERFACE."
        exit 2
    fi

    # Restart the WireGuard interface
    log_with_date "Restarting $WG_INTERFACE"
    if wg-quick up "$WG_INTERFACE"; then
        log_with_date "$WG_INTERFACE successfully restarted."
    else
        log_with_date "Failed to restart $WG_INTERFACE."
        exit 3
    fi
    
    # Log the WireGuard connection status with indentation
    log_with_date "WireGuard connection status:"
    wg | log_wg_status
else
    log_with_date "IP has not changed. No action needed."
fi
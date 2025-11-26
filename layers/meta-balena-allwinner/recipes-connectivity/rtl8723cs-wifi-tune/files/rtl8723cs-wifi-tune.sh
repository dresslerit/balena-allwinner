#!/bin/bash
#
# RTL8723CS WiFi Tuning Script
# Optimizes WiFi settings for better connectivity on weak signals
#

set -e

WLAN_INTERFACE="wlan0"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

log "Starting RTL8723CS WiFi tuning..."

# Wait for interface to be available
timeout=60
while [ $timeout -gt 0 ]; do
    if [ -d "/sys/class/net/$WLAN_INTERFACE" ]; then
        break
    fi
    sleep 1
    timeout=$((timeout - 1))
done

if [ ! -d "/sys/class/net/$WLAN_INTERFACE" ]; then
    log "WiFi interface $WLAN_INTERFACE not found, exiting"
    exit 0
fi

log "Applying optimizations for weak signal handling..."

# Disable power save mode at the interface level
if command -v iw &>/dev/null; then
    iw dev "$WLAN_INTERFACE" set power_save off || true
    log "Power save disabled on $WLAN_INTERFACE"
fi

# Set TX power to maximum and increase retries
if command -v iwconfig &>/dev/null; then
    iwconfig "$WLAN_INTERFACE" txpower auto || true
    # Increase retry limit to help with packet loss
    iwconfig "$WLAN_INTERFACE" retry 7 || true
    log "TX power set to auto, retries increased"
fi

# Adjust WiFi retry parameters if available
if [ -d "/sys/module/8723cs/parameters" ]; then
    # These settings improve reliability on weak signals
    
    # Ensure power management is disabled
    echo 0 > /sys/module/8723cs/parameters/rtw_power_mgnt 2>/dev/null || true
    echo 0 > /sys/module/8723cs/parameters/rtw_ips_mode 2>/dev/null || true
    
    # Disable BT coexistence to prevent interference if not needed
    echo 0 > /sys/module/8723cs/parameters/rtw_btcoex_enable 2>/dev/null || true
    
    log "RTL8723CS driver parameters tuned (Power Mgmt: 0, IPS: 0, BT Coex: 0)"
fi

# Optimize kernel network stack for WiFi (BBR handles packet loss better)
if grep -q bbr /proc/sys/net/ipv4/tcp_available_congestion_control 2>/dev/null; then
    sysctl -w net.ipv4.tcp_congestion_control=bbr 2>/dev/null || true
    log "TCP congestion control set to BBR"
fi

# Log driver statistics for monitoring
if command -v ethtool &>/dev/null; then
    log "Recording WiFi driver statistics..."
    ethtool -S "$WLAN_INTERFACE" > /var/log/wifi_stats_$(date +%Y%m%d_%H%M%S).log 2>&1 || true
fi

# Log current driver module parameters
if [ -d "/sys/module/8723cs/parameters" ]; then
    log "Driver parameters:"
    for param in /sys/module/8723cs/parameters/*; do
        if [ -f "$param" ]; then
            log "  $(basename $param) = $(cat $param 2>/dev/null || echo 'N/A')"
        fi
    done
fi

log "RTL8723CS WiFi tuning completed successfully"
exit 0

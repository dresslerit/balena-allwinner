#!/bin/bash
#
# WiFi Recovery Service
# Monitors WiFi connection and takes recovery actions
#

INTERFACE="wlan0"
CHECK_INTERVAL=30
MAX_FAILURES=3
GATEWAY=""

log() {
    logger -t wifi-recovery "$1"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

get_gateway() {
    ip route | awk '/default via/ {print $3; exit}'
}

check_interface_up() {
    # Check if interface exists and is up
    if ! ip link show "$INTERFACE" up &>/dev/null 2>&1; then
        return 1
    fi
    return 0
}

check_link() {
    # Check if interface is up
    if ! check_interface_up; then
        log "Interface $INTERFACE is not up"
        return 1
    fi
    
    # Check if associated with AP
    if command -v iw &>/dev/null; then
        if ! iw dev "$INTERFACE" link 2>/dev/null | grep -q "Connected"; then
            log "Interface $INTERFACE not connected to AP"
            return 1
        fi
    fi
    
    return 0
}

check_connectivity() {
    GATEWAY=$(get_gateway)
    
    if [ -z "$GATEWAY" ]; then
        log "No gateway found for connectivity check"
        return 1
    fi
    
    # Ping gateway with timeout
    if ! ping -c 2 -W 5 "$GATEWAY" &>/dev/null; then
        log "Gateway $GATEWAY unreachable"
        return 1
    fi
    
    return 0
}

recovery_action() {
    local level=$1
    
    log "Initiating recovery action level $level"
    
    case $level in
        1)
            # Level 1: Restart NetworkManager
            log "Level 1: Restarting NetworkManager service"
            systemctl restart NetworkManager
            sleep 10
            ;;
        2)
            # Level 2: Bounce interface
            log "Level 2: Bouncing $INTERFACE"
            if check_interface_up; then
                ip link set "$INTERFACE" down
                sleep 2
                ip link set "$INTERFACE" up
                sleep 5
            fi
            systemctl restart NetworkManager
            sleep 10
            ;;
        3)
            # Level 3: Reload driver module
            log "Level 3: Reloading 8723cs kernel module"
            
            # Stop NetworkManager first
            systemctl stop NetworkManager
            sleep 2
            
            # Unload and reload module
            if lsmod | grep -q 8723cs; then
                modprobe -r 8723cs || log "Warning: Failed to unload 8723cs module"
                sleep 2
            fi
            
            modprobe 8723cs || log "Warning: Failed to load 8723cs module"
            sleep 5
            
            # Restart NetworkManager
            systemctl start NetworkManager
            sleep 10
            ;;
    esac
    
    log "Recovery action level $level completed"
}

# Main monitoring loop
log "WiFi recovery service started for interface $INTERFACE"

failure_count=0
recovery_level=1
consecutive_successes=0

while true; do
    sleep $CHECK_INTERVAL
    
    # Check link status
    link_ok=false
    conn_ok=false
    
    if check_link; then
        link_ok=true
        
        # Only check connectivity if link is up
        if check_connectivity; then
            conn_ok=true
        fi
    fi
    
    # Evaluate health
    if $link_ok && $conn_ok; then
        # Connection is healthy
        consecutive_successes=$((consecutive_successes + 1))
        
        if [ $failure_count -gt 0 ] && [ $consecutive_successes -ge 2 ]; then
            log "Connection recovered and stable (${consecutive_successes} consecutive successes)"
            failure_count=0
            recovery_level=1
        fi
        
        # Reset consecutive successes counter after stability established
        if [ $consecutive_successes -ge 5 ]; then
            consecutive_successes=5  # Cap to prevent overflow
        fi
        
        continue
    fi
    
    # Connection problem detected
    consecutive_successes=0
    failure_count=$((failure_count + 1))
    
    if ! $link_ok; then
        log "Link failure detected (count: $failure_count)"
    elif ! $conn_ok; then
        log "Connectivity failure detected (count: $failure_count)"
    fi
    
    # Take action after MAX_FAILURES
    if [ $failure_count -ge $MAX_FAILURES ]; then
        log "Maximum failures ($MAX_FAILURES) reached, initiating recovery"
        
        recovery_action $recovery_level
        
        # Reset counter after action
        failure_count=0
        
        # Wait for recovery to take effect
        sleep 20
        
        # Escalate recovery level if still failing
        recovery_level=$((recovery_level + 1))
        if [ $recovery_level -gt 3 ]; then
            log "Maximum recovery level reached, resetting to level 1"
            recovery_level=1  # Cycle back to start
        fi
    fi
done

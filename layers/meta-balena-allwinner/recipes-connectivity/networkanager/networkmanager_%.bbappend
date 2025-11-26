do_install:append() {
    cat << EOF >> ${D}${sysconfdir}/NetworkManager/NetworkManager.conf

[connectivity]
# Enable connectivity checking to detect dead connections
uri=http://nmcheck.gnome.org/check_network_status.txt
interval=300
response=NetworkManager is online

[device]
wifi.scan-rand-mac-address=no

[connection]
# Increase WiFi timeouts for better handling of weak signals
ipv4.dhcp-timeout=90
ipv6.dhcp-timeout=90
# Disable WiFi power management for all connections (0=off, 2=on, 3=default)
wifi.powersave=2
EOF

    # Install WiFi monitoring dispatcher script
    install -d ${D}${libdir}/NetworkManager/dispatcher.d/
    cat > ${D}${libdir}/NetworkManager/dispatcher.d/95-wifi-monitor << 'DISPATCHER_EOF'
#!/bin/bash
# NetworkManager dispatcher script for WiFi monitoring

INTERFACE=$1
ACTION=$2

if [ "$INTERFACE" != "wlan0" ]; then
    exit 0
fi

case "$ACTION" in
    up)
        logger -t wifi-monitor "WiFi connection established on $INTERFACE"
        # Reset failure counter
        echo 0 > /var/run/wifi_failure_count 2>/dev/null || true
        # Log signal strength
        if command -v iw &>/dev/null; then
            iw dev "$INTERFACE" link | grep signal | logger -t wifi-monitor
        fi
        ;;
    down)
        logger -t wifi-monitor "WiFi connection lost on $INTERFACE"
        # Increment failure counter
        COUNT=$(cat /var/run/wifi_failure_count 2>/dev/null || echo 0)
        COUNT=$((COUNT + 1))
        echo $COUNT > /var/run/wifi_failure_count 2>/dev/null || true
        
        # Log multiple failures
        if [ $COUNT -ge 3 ]; then
            logger -t wifi-monitor "WARNING: Multiple failures detected ($COUNT)"
        fi
        ;;
    connectivity-change)
        logger -t wifi-monitor "Connectivity state changed: $CONNECTIVITY_STATE"
        ;;
esac

exit 0
DISPATCHER_EOF
    chmod 0755 ${D}${libdir}/NetworkManager/dispatcher.d/95-wifi-monitor
}

do_install:append() {
    cat << EOF >> ${D}${sysconfdir}/NetworkManager/NetworkManager.conf

[device]
wifi.scan-rand-mac-address=no

[connection]
# Increase WiFi timeouts for better handling of weak signals
ipv4.dhcp-timeout=90
ipv6.dhcp-timeout=90
# Disable WiFi power management for all connections (0=off, 2=on, 3=default)
wifi.powersave=2
EOF
}

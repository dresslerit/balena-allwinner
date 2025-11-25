do_install:append() {
    cat << EOF >> ${D}${sysconfdir}/NetworkManager/NetworkManager.conf

[device]
wifi.scan-rand-mac-address=no

[connection]
# Increase WiFi timeouts for better handling of weak signals
ipv4.dhcp-timeout=90
ipv6.dhcp-timeout=90

[wifi]
# Disable powersave to improve connectivity on weak signals
powersave=2
# Increase background scan interval (seconds)
scan-rand-mac-address=no
backend=wpa_supplicant
EOF
}

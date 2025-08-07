do_install:append() {
    cat << EOF >> ${D}${sysconfdir}/NetworkManager/NetworkManager.conf

[device]
wifi.scan-rand-mac-address=no
EOF
}

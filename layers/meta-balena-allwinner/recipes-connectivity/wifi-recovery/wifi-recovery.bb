SUMMARY = "WiFi connection recovery service"
DESCRIPTION = "Monitors WiFi connection health and performs automated recovery actions"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10"

SRC_URI = " \
    file://wifi-recovery.service \
    file://wifi-recovery.sh \
"

inherit systemd

SYSTEMD_SERVICE:${PN} = "wifi-recovery.service"
SYSTEMD_AUTO_ENABLE = "enable"

RDEPENDS:${PN} = "bash iproute2 iputils"

do_install() {
    # Install systemd service
    install -d ${D}${systemd_unitdir}/system/
    install -m 0644 ${WORKDIR}/wifi-recovery.service ${D}${systemd_unitdir}/system/

    # Install recovery script
    install -d ${D}${sbindir}
    install -m 0755 ${WORKDIR}/wifi-recovery.sh ${D}${sbindir}/
}

FILES:${PN} += "${systemd_unitdir}/system/wifi-recovery.service"
FILES:${PN} += "${sbindir}/wifi-recovery.sh"

SUMMARY = "RTL8723CS WiFi tuning for weak signal handling"
DESCRIPTION = "Optimizes RTL8723CS WiFi driver settings for better connectivity on weak signals"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10"

SRC_URI = " \
    file://rtl8723cs-wifi-tune.service \
    file://rtl8723cs-wifi-tune.sh \
"

inherit systemd

SYSTEMD_SERVICE:${PN} = "rtl8723cs-wifi-tune.service"

RDEPENDS:${PN} = "bash iw"

do_install() {
    install -d ${D}${systemd_unitdir}/system
    install -m 0644 ${WORKDIR}/rtl8723cs-wifi-tune.service ${D}${systemd_unitdir}/system/

    install -d ${D}${sbindir}
    install -m 0755 ${WORKDIR}/rtl8723cs-wifi-tune.sh ${D}${sbindir}/
}

FILES:${PN} += "${systemd_unitdir}/system/rtl8723cs-wifi-tune.service"
FILES:${PN} += "${sbindir}/rtl8723cs-wifi-tune.sh"

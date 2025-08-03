SUMMARY = "Realtek RTL8723CS wifi driver"
LICENSE = "GPLv2"
LIC_FILES_CHKSUM = "file://Kconfig;md5=8e8dfd972599a132da33bd39ae670b98"

inherit module

SRC_URI = "git://github.com/Icenowy/rtl8723cs.git;protocol=https;branch=master \
           file://8723cs.conf \
          "

SRCREV = "${AUTOREV}"
S = "${WORKDIR}/git"

# Pass KSRC to the Makefile, pointing to the correct kernel source for the target.
EXTRA_OEMAKE = "KSRC=${STAGING_KERNEL_DIR}"

# This is the most important change. It disables the automatic creation of a
# separate 'kernel-module-rtl8723cs' package and forces everything
# into the main package.
PACKAGES = "${PN}"

do_install() {
    # This installs the module to the default non-compliant location: ${D}/lib/modules
    oe_runmake -C ${STAGING_KERNEL_DIR} M=${S} modules_install INSTALL_MOD_PATH=${D}

    # Now, move the files to the usrmerge compliant location
    if [ -d ${D}/lib/modules ]; then
        install -d ${D}${nonarch_base_libdir}
        mv ${D}/lib/modules ${D}${nonarch_base_libdir}/
        rm -rf ${D}/lib
    fi

    # Install the modprobe configuration file
    install -d ${D}${sysconfdir}/modprobe.d
    install -m 0644 ${WORKDIR}/8723cs.conf ${D}${sysconfdir}/modprobe.d/
}

# This now correctly points to the location where we moved the module
FILES_${PN} = " \
    ${sysconfdir}/modprobe.d/8723cs.conf \
    ${nonarch_base_libdir}/modules/${KERNEL_VERSION}/extra/8723cs.ko \
"
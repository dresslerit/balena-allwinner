inherit resin-u-boot
UBOOT_KCONFIG_SUPPORT = "1"

FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

# Remove patch inherited from meta-resin. This needs to be rebased for v2018.07
SRC_URI:remove = " file://resin-specific-env-integration-kconfig.patch "

SRC_URI += " \
    file://0001-Integrate-machine-independent-resin-environment-conf.patch \
    file://revert_env_erase_ptr.patch \
"

SRC_URI:append:ty33a-8g1g = " file://ty33a_8g1g_defconfig file://sun8i-a33-ty33a-8g1g.dts file://0003-Add-sun8i-a33-ty33a-8g1g-device-tree-to-Makefile.patch"

do_configure:prepend:ty33a-8g1g() {
    if [ -f ${WORKDIR}/ty33a_8g1g_defconfig ]; then
        cp ${WORKDIR}/ty33a_8g1g_defconfig ${S}/configs/
    fi
    if [ -f ${WORKDIR}/sun8i-a33-ty33a-8g1g.dts ]; then
        cp ${WORKDIR}/sun8i-a33-ty33a-8g1g.dts ${S}/arch/arm/dts/
    fi
}
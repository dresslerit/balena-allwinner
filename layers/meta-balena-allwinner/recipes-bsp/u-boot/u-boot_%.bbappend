UBOOT_KCONFIG_SUPPORT = "1"
inherit resin-u-boot
FILESEXTRAPATHS_append := ":${THISDIR}/files"

# remove the resin-specific-env-integration-kconfig.patch patch from
# meta-sunxi because it fails to apply
SRC_URI_remove = "file://resin-specific-env-integration-kconfig.patch"

# Add re-worked patch resin-specific-env-integration-kconfig_reworked.patch
SRC_URI_append = " \
		file://0001-Add-Resin-specific-boot-command.patch \
		file://resin-specific-env-integration-kconfig_reworked.patch \
		file://0002-Change_CONFIG_SYS_BOOTM_LEN_to_64M.patch \
		"
SRC_URI_append_ty33a-8g1g = " file://ty33a_8g1g_defconfig file://sun8i-a33-ty33a-8g1g.dts file://0003-Add-sun8i-a33-ty33a-8g1g-device-tree-to-Makefile.patch"

do_configure_prepend_ty33a-8g1g() {
    if [ -f ${WORKDIR}/ty33a_8g1g_defconfig ]; then
        cp ${WORKDIR}/ty33a_8g1g_defconfig ${S}/configs/
    fi
    if [ -f ${WORKDIR}/sun8i-a33-ty33a-8g1g.dts ]; then
        cp ${WORKDIR}/sun8i-a33-ty33a-8g1g.dts ${S}/arch/arm/dts/
    fi
}
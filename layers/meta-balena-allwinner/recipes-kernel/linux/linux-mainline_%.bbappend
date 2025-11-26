inherit kernel-resin
inherit kernel-devicetree

PACKAGES =+ "${PN}-fixup-scr"

SRC_URI:remove = "file://0003-ARM-dts-nanopi-neo-air-Add-WiFi-eMMC.patch"

FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI:append:nanopi-neo-air = " \
    file://nanopi-neo-air/0001-linux-mainline-Add-back-eMMC-support-for-Nanopi-Neo-.patch \
    file://nanopi-neo-air/board-nanopiair-h3-camera-wifi-bluetooth-otg.patch \
"

SRC_URI:append:ty33a-8g1g = " \
    file://ty33a-8g1g/defconfig \
    file://ty33a-8g1g/sun8i-a33-ty33a-8g1g.dts \
    file://wireless-rtl8723cs/8723cs-Add-a-new-driver-v5.12.2-7-g2de5ec386.20201013_beta.patch \
    file://wireless-rtl8723cs/8723cs-Make-the-driver-compile-and-probe-drop-rockchip-platform.patch \
    file://wireless-rtl8723cs/8723cs-Enable-OOB-interrupt.patch \
    file://wireless-rtl8723cs/8723cs-Load-the-MAC-address-from-local-mac-address.patch \
    file://wireless-rtl8723cs/8723cs-Modify-makefile-options-to-better-suit-PinePhone-Allwinn.patch \
    file://wireless-rtl8723cs/8723cs-Enable-monitor-mode.patch \
    file://wireless-rtl8723cs/8723cs-Disable-power-saving.patch \
    file://wireless-rtl8723cs/8723cs-aes_encrypt-aes_encrypt_128-to-avoid-symbol-name-conflic.patch \
    file://wireless-rtl8723cs/8723cs-Enable-TDLS-802.11z-support-direct-sta-sta-connection.patch \
    file://wireless-rtl8723cs/8723cs-Disable-CONFIG_CONCURRENT_MODE.patch \
    file://wireless-rtl8723cs/8723cs-Set-CONFIG_RTW_SDIO_PM_KEEP_POWER-n-to-fix-suspend-38.patch \
    file://wireless-rtl8723cs/8723cs-Resume-wifi-in-a-workqueue.patch \
    file://wireless-rtl8723cs/8723cs-Port-to-5.11.patch \
    file://wireless-rtl8723cs/8723cs-Enable-WoWLAN.patch \
    file://wireless-rtl8723cs/8723cs-Port-to-5.12.patch \
    file://wireless-rtl8723cs/8723cs-Fix-misleading-indentation.patch \
    file://wireless-rtl8723cs/8723cs-Disable-use-of-NAPI.patch \
    file://wireless-rtl8723cs/8723cs-Fix-indentation.patch \
    file://wireless-rtl8723cs/8723cs-Fix-compile-warnings.patch \
    file://wireless-rtl8723cs/8723cs-Port-to-5.15.patch \
    file://wireless-rtl8723cs/8723cs.conf \
"


do_configure:append:ty33a-8g1g() {
    # Wire up drivers/staging/rtl8723cs in the Makefile if missing
    if ! grep -qE '^obj-\$\((CONFIG_RTL8723CS)\)[[:space:]]*\+=\s*rtl8723cs/' \
        ${S}/drivers/staging/Makefile; then
        # Insert just after the existing rtl8723bs line for stability
        sed -i '/^obj-\$(CONFIG_RTL8723BS)[[:space:]]*+=\s*rtl8723bs\//a obj-$(CONFIG_RTL8723CS)        += rtl8723cs/' \
            ${S}/drivers/staging/Makefile
    fi
}

do_install:append:ty33a-8g1g() {
    # Install modprobe configuration to disable power management for RTL8723CS
    install -d ${D}${sysconfdir}/modprobe.d
    install -m 0644 ${WORKDIR}/wireless-rtl8723cs/8723cs.conf ${D}${sysconfdir}/modprobe.d/
}

FILES:${PN}:append:ty33a-8g1g = " ${sysconfdir}/modprobe.d/8723cs.conf"

BALENA_CONFIGS:append = " axp_power"
BALENA_CONFIGS_DEPS[axp_power] = "\
    CONFIG_TOUCHSCREEN_SUN4I=n \
    CONFIG_IIO=y \
    CONFIG_REGMAP_IRQ=y \
    CONFIG_MFD_SUN4I_GPADC=y \
    CONFIG_MFD_AXP20X=y \
    CONFIG_MFD_AXP20X_I2C=y \
"
BALENA_CONFIGS[axp_power] ="\
    CONFIG_AXP20X_POWER=y \
"

# Enable RTL8723CS in the kernel
BALENA_CONFIGS:append:ty33a-8g1g = " rtl8723cs"

# Staging needs to be on for the menu to show up
BALENA_CONFIGS_DEPS[rtl8723cs] = " \
    CONFIG_STAGING=y \
"

# Build the driver as a module
BALENA_CONFIGS[rtl8723cs] = " \
    CONFIG_RTL8723CS=m \
"


BALENA_CONFIGS:append:orangepi-plus2 = " wifi"
BALENA_CONFIGS:append:orange-pi-zero = " wifi"
BALENA_CONFIGS:append:orange-pi-lite = " wifi"
BALENA_CONFIGS:append:nanopi-neo-air = " wifi"
BALENA_CONFIGS:append:bananapi-m1-plus = " wifi"
BALENA_CONFIGS:append:ty33a-8g1g= " wifi initramfs"

BALENA_CONFIGS[initramfs] = "\
    CONFIG_BLK_DEV_RAM=y \
    CONFIG_BLK_DEV_INITRD=y \
"

KERNEL_DEVICETREE_ty33a-8g1g = "sun8i-a33-ty33a-8g1g.dtb"

BALENA_CONFIGS[wifi] ="\
    CONFIG_WIRELESS=y \
    CONFIG_RFKILL=y \
    CONFIG_CFG80211=m \
    CONFIG_CFG80211_WEXT=y \
    CONFIG_WLAN=y \
    CONFIG_WLAN_VENDOR_REALTEK=y \
"

BALENA_CONFIGS:append:orangepi-plus2 = " hdmi"
BALENA_CONFIGS_DEPS[hdmi] = "\
    CONFIG_DRM=y \
    CONFIG_DRM_SUN4I=y \
    CONFIG_SUN8I_DE2_CCU=y \
"
BALENA_CONFIGS[hdmi] ="\
    CONFIG_DRM_SUN8I_DW_HDMI=y \
"

BALENA_CONFIGS:append = " huawei_modems"
BALENA_CONFIGS_DEPS[huawei_modems] = "\
    CONFIG_USB_SERIAL_OPTION=m \
    CONFIG_USB_USBNET=m \
"
BALENA_CONFIGS[huawei_modems] ="\
    CONFIG_USB_NET_HUAWEI_CDC_NCM=m \
"

BALENA_CONFIGS:append = " cp210x"
BALENA_CONFIGS[cp210x] ="\
    CONFIG_USB_SERIAL_CP210X=m \
"

BALENA_CONFIGS:append:orange-pi-lite = " \
    8189fs \
    "


BALENA_CONFIGS[8189fs] ?= " \
    CONFIG_RTL8189FS=m \
"

BALENA_CONFIGS:append = " \
    configfs \
"

BALENA_CONFIGS[configfs] = " \
    CONFIG_OF_CONFIGFS=y \
    CONFIG_OF_OVERLAY=y \
    CONFIG_CONFIGFS_FS=y \
"

BALENA_CONFIGS:append:nanopi-neo-air = " hciuart"
BALENA_CONFIGS_DEPS[hciuart] = " \
    CONFIG_BT=m \
"
BALENA_CONFIGS[hciuart] = " \
    CONFIG_BT_HCIUART=m \
    CONFIG_BT_HCIUART_H4=y \
"

FILES_${PN}-fixup-scr = " \
    /boot/sun8i-h3-fixup.scr \
"
KERNEL_DEVICETREE:orange-pi-zero:append = " \
    sun8i-h2-plus-orangepi-zero.dtb \
    overlay/sun8i-h3-analog-codec.dtbo \
    overlay/sun8i-h3-cir.dtbo \
    overlay/sun8i-h3-fixup.scr \
    overlay/sun8i-h3-i2c0.dtbo \
    overlay/sun8i-h3-i2c1.dtbo \
    overlay/sun8i-h3-i2c2.dtbo \
    overlay/sun8i-h3-pps-gpio.dtbo \
    overlay/sun8i-h3-pwm.dtbo \
    overlay/sun8i-h3-spdif-out.dtbo \
    overlay/sun8i-h3-spi-add-cs1.dtbo \
    overlay/sun8i-h3-spi-jedec-nor.dtbo \
    overlay/sun8i-h3-spi-spidev.dtbo \
    overlay/sun8i-h3-uart1.dtbo \
    overlay/sun8i-h3-uart2.dtbo \
    overlay/sun8i-h3-uart3.dtbo \
    overlay/sun8i-h3-usbhost0.dtbo \
    overlay/sun8i-h3-usbhost2.dtbo \
    overlay/sun8i-h3-usbhost3.dtbo \
    overlay/sun8i-h3-w1-gpio.dtbo \
    "

do_configure:prepend:ty33a-8g1g() {
    # 1. Put the defconfig where the kernel expects it
    install -m0644  ${WORKDIR}/ty33a-8g1g/defconfig \
        ${S}/arch/arm/configs/ty33a_8g1g_defconfig

    # 2. Drop the board dts into the dts directory
    install -m0644  ${WORKDIR}/ty33a-8g1g/sun8i-a33-ty33a-8g1g.dts \
        ${S}/arch/arm/boot/dts/

    # 3. Register the dtb once—no duplicate targets
    if ! grep -q "sun8i-a33-ty33a-8g1g.dtb" \
        ${S}/arch/arm/boot/dts/Makefile; then
        sed -i '/dtb-\$(CONFIG_MACH_SUN8I)/a\	sun8i-a33-ty33a-8g1g.dtb \\' ${S}/arch/arm/boot/dts/Makefile
    fi
}

do_install:append:ty33a-8g1g() {
    # Install module configuration for 8723cs driver
    install -d ${D}${sysconfdir}/modprobe.d
    install -m 0644 ${WORKDIR}/wireless-rtl8723cs/8723cs.conf ${D}${sysconfdir}/modprobe.d/
}


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
"

SRC_URI:append = " \
    file://general-add-configfs-overlay.patch \
    file://general-add-overlay-compilation-support.patch \
    file://general-sunxi-overlays.patch \
    file://0001-arch-arm-Makefile-Partial-revert-of-https-github.com.patch \
"

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

BALENA_CONFIGS:append:orangepi-plus2 = " wifi"
BALENA_CONFIGS:append:orange-pi-zero = " wifi"
BALENA_CONFIGS:append:orange-pi-lite = " wifi"
BALENA_CONFIGS:append:nanopi-neo-air = " wifi"
BALENA_CONFIGS:append:bananapi-m1-plus = " wifi"
BALENA_CONFIGS:append:ty33a-8g1g= " wifi"




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


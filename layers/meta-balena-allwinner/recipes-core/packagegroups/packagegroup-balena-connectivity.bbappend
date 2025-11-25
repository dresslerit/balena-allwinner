CONNECTIVITY_FIRMWARES:append:bananapi-m1-plus = " linux-firmware-ap6212"
CONNECTIVITY_FIRMWARES:append = " linux-firmware-bcm43362"
CONNECTIVITY_MODULES:append:orangepi-plus2 = " rtl8189"

CONNECTIVITY_MODULES:append:orange-pi-zero = " xradio"
CONNECTIVITY_FIRMWARES:append:orange-pi-zero = " xradio-firmware"

CONNECTIVITY_FIRMWARES:append:nanopi-neo-air = " linux-firmware-bcm43430"

# TY33A WiFi optimization for weak signals
RDEPENDS:${PN}:append:ty33a-8g1g = " rtl8723cs-wifi-tune"

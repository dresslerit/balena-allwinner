#
# ty33a-8g1g 
#

IMAGE_FSTYPES:append:ty33a-8g1g = " balenaos-img"

# Customize balenaos-img
BALENA_IMAGE_BOOTLOADER:ty33a-8g1g= "u-boot"
BALENA_BOOT_PARTITION_FILES:ty33a-8g1g = " \
    ${KERNEL_IMAGETYPE}${KERNEL_INITRAMFS}-${MACHINE}.bin:/${KERNEL_IMAGETYPE} \
    ${KERNEL_DEVICETREE}:/dtb/${KERNEL_DEVICETREE} \
    u-boot-sunxi-with-spl.bin: \
"
IMAGE_CMD_balenaos-img:append:ty33a-8g1g() {
    echo "=== TY33A IMAGE_CMD_balenaos-img EXECUTING ==="
    echo "DEPLOY_DIR_IMAGE: ${DEPLOY_DIR_IMAGE}"
    echo "BALENA_RAW_IMG: ${BALENA_RAW_IMG}"
    ls -la "${DEPLOY_DIR_IMAGE}/u-boot-sunxi-with-spl.bin" || echo "ERROR: u-boot-sunxi-with-spl.bin not found"
    
    # ty33a-8g1g needs uboot written at a specific location
    echo "Running: dd if=${DEPLOY_DIR_IMAGE}/u-boot-sunxi-with-spl.bin of=${BALENA_RAW_IMG} conv=notrunc seek=8 bs=1024"
    dd if=${DEPLOY_DIR_IMAGE}/u-boot-sunxi-with-spl.bin of=${BALENA_RAW_IMG} conv=notrunc seek=8 bs=1024
    echo "=== TY33A IMAGE_CMD_balenaos-img COMPLETED ==="
}

device_specific_configuration:ty33a-8g1g() {
    echo "=== TY33A DEVICE SPECIFIC CONFIGURATION ==="
    echo "DEPLOY_DIR_IMAGE: ${DEPLOY_DIR_IMAGE}"
    echo "BALENA_RAW_IMG: ${BALENA_RAW_IMG}"
    ls -la "${DEPLOY_DIR_IMAGE}/u-boot-sunxi-with-spl.bin" || echo "ERROR: u-boot-sunxi-with-spl.bin not found"
    
    # ty33a-8g1g needs uboot written at a specific location
    echo "Running: dd if=${DEPLOY_DIR_IMAGE}/u-boot-sunxi-with-spl.bin of=${BALENA_RAW_IMG} conv=notrunc seek=8 bs=1024"
    dd if=${DEPLOY_DIR_IMAGE}/u-boot-sunxi-with-spl.bin of=${BALENA_RAW_IMG} conv=notrunc seek=8 bs=1024
    echo "=== TY33A DEVICE SPECIFIC CONFIGURATION COMPLETED ==="
}




#
# Orange Pi Plus2
#

IMAGE_FSTYPES:append:orangepi-plus2 = " balenaos-img"

# Customize balenaos-img
BALENA_IMAGE_BOOTLOADER:orangepi-plus2 = "u-boot"
BALENA_BOOT_PARTITION_FILES:orangepi-plus2 = " \
    ${KERNEL_IMAGETYPE}${KERNEL_INITRAMFS}-${MACHINE}.bin:/${KERNEL_IMAGETYPE} \
    sun8i-h3-orangepi-plus.dtb:/dtb/sun8i-h3-orangepi-plus.dtb \
    u-boot-sunxi-with-spl.bin: \
"
IMAGE_CMD_balenaos-img:append:orangepi-plus2 () {
    # Orange Pi Plus2 needs uboot written at a specific location
    dd if=${DEPLOY_DIR_IMAGE}/u-boot-sunxi-with-spl.bin of=${BALENA_RAW_IMG} conv=notrunc seek=8 bs=1024
}

#
# Orange Pi One
#

IMAGE_FSTYPES:append:orange-pi-one = " balenaos-img"

# Customize balenaos-img
BALENA_IMAGE_BOOTLOADER:orange-pi-one = "u-boot"
BALENA_BOOT_PARTITION_FILES:orange-pi-one = " \
    ${KERNEL_IMAGETYPE}${KERNEL_INITRAMFS}-${MACHINE}.bin:/${KERNEL_IMAGETYPE} \
    sun8i-h3-orangepi-one.dtb:/dtb/sun8i-h3-orangepi-one.dtb \
    u-boot-sunxi-with-spl.bin: \
"
IMAGE_CMD_balenaos-img:append:orange-pi-one () {
    # Orange Pi One needs uboot written at a specific location
    dd if=${DEPLOY_DIR_IMAGE}/u-boot-sunxi-with-spl.bin of=${BALENA_RAW_IMG} conv=notrunc seek=8 bs=1024
}


#
# bananapi-M1+
#

IMAGE_FSTYPES:append:bananapi-m1-plus = " balenaos-img"

# Customize balenaos-img
BALENA_IMAGE_BOOTLOADER:bananapi-m1-plus = "u-boot"
BALENA_BOOT_PARTITION_FILES:bananapi-m1-plus = " \
    ${KERNEL_IMAGETYPE}${KERNEL_INITRAMFS}-${MACHINE}.bin:/${KERNEL_IMAGETYPE} \
    sun7i-a20-bananapi-m1-plus.dtb:/dtb/sun7i-a20-bananapi-m1-plus.dtb\
    u-boot-sunxi-with-spl.bin: \
"
IMAGE_CMD_balenaos-img:append:bananapi-m1-plus () {
    # bananapi-M1+ needs uboot written at a specific location
    dd if=${DEPLOY_DIR_IMAGE}/u-boot-sunxi-with-spl.bin of=${BALENA_RAW_IMG} conv=notrunc seek=8 bs=1024
}

#
# orange-pi-lite
#

IMAGE_FSTYPES:append:orange-pi-lite = " balenaos-img"

# Customize balenaos-img
BALENA_IMAGE_BOOTLOADER:orange-pi-lite = "u-boot"
BALENA_BOOT_PARTITION_FILES:orange-pi-lite = " \
    ${KERNEL_IMAGETYPE}${KERNEL_INITRAMFS}-${MACHINE}.bin:/${KERNEL_IMAGETYPE} \
    sun8i-h3-orangepi-lite.dtb:/dtb/sun8i-h3-orangepi-lite.dtb \
    sun8i-h3-fixup.scr:/dtb/overlay/sun8i-h3-fixup.scr \
    sun8i-h3-analog-codec.dtbo:/dtb/overlay/sun8i-h3-analog-codec.dtbo \
    sun8i-h3-cir.dtbo:/dtb/overlay/sun8i-h3-cir.dtbo \
    sun8i-h3-i2c0.dtbo:/dtb/overlay/sun8i-h3-i2c0.dtbo \
    sun8i-h3-i2c1.dtbo:/dtb/overlay/sun8i-h3-i2c1.dtbo \
    sun8i-h3-i2c2.dtbo:/dtb/overlay/sun8i-h3-i2c2.dtbo \
    sun8i-h3-pps-gpio.dtbo:/dtb/overlay/sun8i-h3-pps-gpio.dtbo \
    sun8i-h3-pwm.dtbo:/dtb/overlay/sun8i-h3-pwm.dtbo \
    sun8i-h3-spdif-out.dtbo:/dtb/overlay/sun8i-h3-spdif-out.dtbo \
    sun8i-h3-spi-add-cs1.dtbo:/dtb/overlay/sun8i-h3-spi-add-cs1.dtbo \
    sun8i-h3-spi-jedec-nor.dtbo:/dtb/overlay/sun8i-h3-spi-jedec-nor.dtbo \
    sun8i-h3-spi-spidev.dtbo:/dtb/overlay/sun8i-h3-spi-spidev.dtbo \
    sun8i-h3-uart1.dtbo:/dtb/overlay/sun8i-h3-uart1.dtbo \
    sun8i-h3-uart2.dtbo:/dtb/overlay/sun8i-h3-uart2.dtbo \
    sun8i-h3-uart3.dtbo:/dtb/overlay/sun8i-h3-uart3.dtbo \
    sun8i-h3-usbhost0.dtbo:/dtb/overlay/sun8i-h3-usbhost0.dtbo \
    sun8i-h3-usbhost2.dtbo:/dtb/overlay/sun8i-h3-usbhost1.dtbo \
    sun8i-h3-usbhost3.dtbo:/dtb/overlay/sun8i-h3-usbhost2.dtbo \
    sun8i-h3-w1-gpio.dtbo:/dtb/overlay/sun8i-h3-w1-gpio.dtbo \
    boot.scr:/boot.scr \
    "

IMAGE_CMD_balenaos-img:append:orange-pi-lite () {
    # orange-pi-lite needs uboot written at a specific location
    dd if=${DEPLOY_DIR_IMAGE}/u-boot-sunxi-with-spl.bin of=${BALENA_RAW_IMG} conv=notrunc seek=8 bs=1024
}


#
# Orange Pi Zero
#

IMAGE_FSTYPES:append:orange-pi-zero = " balenaos-img"

#Customize balenaos-img
BALENA_IMAGE_BOOTLOADER:orange-pi-zero = "u-boot"
BALENA_BOOT_PARTITION_FILES:orange-pi-zero = " \
    ${KERNEL_IMAGETYPE}${KERNEL_INITRAMFS}-${MACHINE}.bin:/${KERNEL_IMAGETYPE} \
    sun8i-h2-plus-orangepi-zero.dtb:/dtb/sun8i-h2-plus-orangepi-zero.dtb \
    sun8i-h3-fixup.scr:/dtb/overlay/sun8i-h3-fixup.scr \
    sun8i-h3-analog-codec.dtbo:/dtb/overlay/sun8i-h3-analog-codec.dtbo \
    sun8i-h3-cir.dtbo:/dtb/overlay/sun8i-h3-cir.dtbo \
    sun8i-h3-i2c0.dtbo:/dtb/overlay/sun8i-h3-i2c0.dtbo \
    sun8i-h3-i2c1.dtbo:/dtb/overlay/sun8i-h3-i2c1.dtbo \
    sun8i-h3-i2c2.dtbo:/dtb/overlay/sun8i-h3-i2c2.dtbo \
    sun8i-h3-pps-gpio.dtbo:/dtb/overlay/sun8i-h3-pps-gpio.dtbo \
    sun8i-h3-pwm.dtbo:/dtb/overlay/sun8i-h3-pwm.dtbo \
    sun8i-h3-spdif-out.dtbo:/dtb/overlay/sun8i-h3-spdif-out.dtbo \
    sun8i-h3-spi-add-cs1.dtbo:/dtb/overlay/sun8i-h3-spi-add-cs1.dtbo \
    sun8i-h3-spi-jedec-nor.dtbo:/dtb/overlay/sun8i-h3-spi-jedec-nor.dtbo \
    sun8i-h3-spi-spidev.dtbo:/dtb/overlay/sun8i-h3-spi-spidev.dtbo \
    sun8i-h3-uart1.dtbo:/dtb/overlay/sun8i-h3-uart1.dtbo \
    sun8i-h3-uart2.dtbo:/dtb/overlay/sun8i-h3-uart2.dtbo \
    sun8i-h3-uart3.dtbo:/dtb/overlay/sun8i-h3-uart3.dtbo \
    sun8i-h3-usbhost0.dtbo:/dtb/overlay/sun8i-h3-usbhost0.dtbo \
    sun8i-h3-usbhost2.dtbo:/dtb/overlay/sun8i-h3-usbhost1.dtbo \
    sun8i-h3-usbhost3.dtbo:/dtb/overlay/sun8i-h3-usbhost2.dtbo \
    sun8i-h3-w1-gpio.dtbo:/dtb/overlay/sun8i-h3-w1-gpio.dtbo \
    boot.scr:/boot.scr \
    u-boot-sunxi-with-spl.bin: \
"
IMAGE_CMD_balenaos-img:append:orange-pi-zero () {
    # Orange Pi Zero needs uboot written at a specific location
    dd if=${DEPLOY_DIR_IMAGE}/u-boot-sunxi-with-spl.bin of=${BALENA_RAW_IMG} conv=notrunc seek=8 bs=1024
}

#
# nanopi-neo-air
#

IMAGE_FSTYPES:append:nanopi-neo-air = " balenaos-img"

# Customize balenaos-img
BALENA_IMAGE_BOOTLOADER:nanopi-neo-air = "u-boot"
BALENA_BOOT_PARTITION_FILES:nanopi-neo-air = " \
    ${KERNEL_IMAGETYPE}${KERNEL_INITRAMFS}-${MACHINE}.bin:/${KERNEL_IMAGETYPE} \
    sun8i-h3-nanopi-neo-air.dtb:/dtb/sun8i-h3-nanopi-neo-air.dtb \
    u-boot-sunxi-with-spl.bin: \
    boot.scr:/boot.scr \
    "

IMAGE_CMD_balenaos-img:append:nanopi-neo-air () {
    # nanopi-neo-air needs uboot written at a specific location
    dd if=${DEPLOY_DIR_IMAGE}/u-boot-sunxi-with-spl.bin of=${BALENA_RAW_IMG} conv=notrunc seek=8 bs=1024
}

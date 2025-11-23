FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

# Use Allwinner-specific flasher-board script for eMMC boot partition handling
SRC_URI += "file://resin-init-flasher-board"

#
# Itus Networks Shield Defines
#
ARCH:=mips64
BOARD:=octeon
BOARDNAME:=Itus Networks Shield
FEATURES:=squashfs ramdisk pci usb
CPU_TYPE:=octeon3
MAINTAINER:=Donald Hoskins <grommish@gmail.com>

KERNEL_PATCHVER:=4.19
KERNEL_TESTING_PATCHVER:=5.4

define Target/Description
	Build firmware images for Itus Networks Octeon3-based boards.
endef

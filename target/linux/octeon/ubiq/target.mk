#
# Itus Networks Shield Defines
#
ARCH:=mips64
BOARD:=octeon
BOARDNAME:=Ubiquiti Networks Octeon
FEATURES:=squashfs ramdisk pci usb
CPU_TYPE:=octeonplus
MAINTAINER:=John Crispin <john@phrozen.org>

KERNEL_PATCHVER:=5.4
KERNEL_TESTING_PATCHVER:=5.4

define Target/Description
	Build firmware images for Ubiquiti EdgeRouter/EdgeRouter Lite Octeon-based boards.
endef

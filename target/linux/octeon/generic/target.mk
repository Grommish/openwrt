
ARCH:=mips64
BOARD:=octeon
BOARDNAME:=Generic Cavium Networks Octeon
FEATURES:=squashfs ramdisk pci usb
CPU_TYPE:=octeonplus
MAINTAINER:=John Crispin <john@phrozen.org>

KERNEL_PATCHVER:=5.4
KERNEL_TESTING_PATCHVER:=5.4

SUBTARGETS:=generic itus ubiq

define Target/Description
	Build firmware images for Cavium Networks Octeon-based boards.
endef

#
# Itus Network Shield Profiles
#
ITUSROUTER_CMDLINE:=console=ttyS0,115200, root=/dev/mmcblk1p2 rootfstype=squashfs,ext4,f2fs rootwait
define Device/itusrouter
  DEVICE_VENDOR := Itus Networks
  DEVICE_MODEL := Shield Router
  BOARD_NAME := itusrouter
  CMDLINE := $(ITUSROUTER_CMDLINE)
  IMAGE/sysupgrade.tar :+ append-metadata
endef
TARGET_DEVICES += itusrouter

ITUSBRIDGE_CMDLINE:=console=ttyS0,115200, root=/dev/mmcblk1p4 rootfstype=squashfs,ext4,f2fs rootwait
define Device/itusbridge
  DEVICE_VENDOR := Itus Networks
  DEVICE_MODEL := Shield Bridge
  BOARD_NAME := itusbridge
  CMDLINE := $(ITUSBRIDGE_CMDLINE)
  IMAGE/sysupgrade.tar :+ append-metadata
endef
TARGET_DEVICES += itusbridge

ITUSGATEWAY_CMDLINE:=console=ttyS0,115200, root=/dev/mmcblk1p3 rootfstype=squashfs,ext4,f2fs rootwait
define Device/itusgateway
  DEVICE_VENDOR := Itus Networks
  DEVICE_MODEL := Shield Recovery
  BOARD_NAME := itusgateway
  CMDLINE := $(ITUSGATEWAY_CMDLINE)
  IMAGE/sysupgrade.tar :+ append-metadata
endef
TARGET_DEVICES += itusgateway

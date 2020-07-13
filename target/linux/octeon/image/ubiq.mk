ER_CMDLINE:=-mtdparts=phys_mapped_flash:640k(boot0)ro,640k(boot1)ro,64k(eeprom)ro root=/dev/mmcblk0p2 rootfstype=squashfs,ext4 rootwait
define Device/ubnt_edgerouter
  DEVICE_VENDOR := Ubiquiti
  DEVICE_MODEL := EdgeRouter
  BOARD_NAME := er
  CMDLINE := $(ER_CMDLINE)
endef
TARGET_DEVICES += ubnt_edgerouter

ERLITE_CMDLINE:=-mtdparts=phys_mapped_flash:512k(boot0)ro,512k(boot1)ro,64k(eeprom)ro root=/dev/sda2 rootfstype=squashfs,ext4 rootwait
define Device/ubnt_edgerouter-lite
  DEVICE_VENDOR := Ubiquiti
  DEVICE_MODEL := EdgeRouter Lite
  BOARD_NAME := erlite
  CMDLINE := $(ERLITE_CMDLINE)
endef
TARGET_DEVICES += ubnt_edgerouter-lite

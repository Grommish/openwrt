#
# Copyright (C) 2009-2010 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/image.mk

define Build/strip-kernel
	# Workaround pre-SDK-1.9.0 u-boot versions not handling the .notes section
	$(TARGET_CROSS)strip -R .notes $@ -o $@.stripped && mv $@.stripped $@
endef

define Build/create-itus-sysupgrade
	# Itus Shield requires specialized sysupgrade file
	find $(TOPDIR) -iname openwrt-octeon-* >> $(TOPDIR)/output-$(BOARD_NAME).log
	ls -la $(BIN_DIR) >> $(TOPDIR)/output-$(BOARD_NAME).log
#	tar -C $(BIN_DIR) -xvzf $(BIN_DIR)/openwrt-octeon-$(BOARD_NAME)-ext4-sysupgrade.tar
#	tar -C $(BIN_DIR) -cvzf sysupgrade-$(BOARD_NAME)/kernel openwrt-octeon-rootfs.tar.gz sysupgrade-$(BOARD_NAME).tar.gz
#	rm -rf $(BIN_DIR)/sysupgrade-$(BOARD_NAME)
endef

define Device/Default
  PROFILES = Default $$(DEVICE_NAME)
  KERNEL_NAME := vmlinux.elf
  KERNEL_INITRAMFS_NAME := vmlinux-initramfs.elf
  KERNEL := kernel-bin | strip-kernel | patch-cmdline
  IMAGES := sysupgrade.tar
  IMAGE/sysupgrade.tar/squashfs := append-rootfs | pad-extra 128k | sysupgrade-tar rootfs=$$$$@
  IMAGE/sysupgrade.tar := sysupgrade-tar
endef

include $(SUBTARGET).mk

$(eval $(call BuildImage))

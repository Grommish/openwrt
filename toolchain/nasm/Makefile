#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
include $(TOPDIR)/rules.mk

PKG_NAME:=nasm
PKG_VERSION:=2.15

PKG_SOURCE_URL:=https://www.nasm.us/pub/nasm/releasebuilds/$(PKG_VERSION)/
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz

PKG_HASH:=bc340c2604de5a9aa405b194aae3bcdd86c1631a68a5f4d2165e11d358c2c223

HOST_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/toolchain-build.mk

HOST_CONFIGURE_ARGS+= \
		--target=$(REAL_GNU_TARGET_NAME) \
		--with-sysroot=$(TOOLCHAIN_DIR) \
		--disable-lto \
		--disable-werror \
		--disable-gdb \
		$(SOFT_FLOAT_CONFIG_OPTION) \

define Host/Prepare
	$(call Host/Prepare/Default)
	ln -snf $(notdir $(HOST_BUILD_DIR)) $(BUILD_DIR_TOOLCHAIN)/$(PKG_NAME)
	$(CP) $(SCRIPT_DIR)/config.{guess,sub} $(HOST_BUILD_DIR)/
endef

define Host/Configure
	(cd $(HOST_BUILD_DIR); \
		./autogen.sh \
	);
	$(call Host/Configure/Default)
endef

define Host/Install
	$(MAKE) -C $(HOST_BUILD_DIR) \
		$(HOST_MAKE_FLAGS) \
		prefix=$(TOOLCHAIN_DIR) \
		install
endef

define Host/Clean
	rm -rf \
		$(HOST_BUILD_DIR) \
		$(BUILD_DIR_TOOLCHAIN)/$(PKG_NAME)
endef

$(eval $(call HostBuild))

#
# Copyright (C) 2020 muink <https://github.com/muink>
#
# This is free software, licensed under the MIT License
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

LUCI_NAME:=luci-app-change-mac
PKG_VERSION:=0.2.0
PKG_RELEASE:=1

LUCI_TITLE:=LuCI for MAC address randomizer
LUCI_DEPENDS:=+luci-compat +bash +rgmac +getopt

LUCI_DESCRIPTION:=Assign a random MAC address to the designated interface on every time boot.

define Package/$(LUCI_NAME)/conffiles
/etc/config/change-mac
endef

define Package/$(LUCI_NAME)/prerm
#!/bin/sh
/etc/init.d/change-mac stop
/etc/init.d/change-mac disable
endef

include $(TOPDIR)/feeds/luci/luci.mk

# call BuildPackage - OpenWrt buildroot signature

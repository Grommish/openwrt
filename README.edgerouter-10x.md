# OpenWrt support for the Ubiquiti EdgeRouter 10X

Adds the EdgeRouter 10X (`ubnt,edgerouter-10x`) to `ramips/mt7621`, together with
the generic DSA fix the board needs. Three commits: the kernel fix, the board
support, and this note.

## Base

This work sits on **openwrt/openwrt** at:

    19ff245b9233060bcbf55ec50cc3086d4348b72c   (2026-09-01)

It is a snapshot, not a maintained branch -- it will not be rebased to follow
upstream. Against a much later tree expect to fix up `mt7621.mk`,
`board.d/02_network` and `lib/upgrade/platform.sh` by hand; all three are small,
additive hunks.

## Applying

Fetch the series straight from the fork and apply it to a pristine tree:

    git clone https://github.com/openwrt/openwrt.git
    cd openwrt
    git checkout 19ff245b9233060bcbf55ec50cc3086d4348b72c
    curl -L https://github.com/Grommish/openwrt/compare/19ff245b9233060bcbf55ec50cc3086d4348b72c...er10x-dsa.patch | git am

Or just take the branch whole:

    git remote add grommish https://github.com/Grommish/openwrt.git
    git fetch grommish er10x-dsa
    git checkout grommish/er10x-dsa

Patch files can also be applied without git history:

    git apply 0001-*.patch 0002-*.patch      # 0003 is this file

## Building

    ./scripts/feeds update -a && ./scripts/feeds install -a
    make menuconfig      # Target: Ramips -> Subtarget: MT7621 -> Profile: Ubiquiti EdgeRouter 10X
    make -j$(nproc)

Output is `initramfs-kernel.bin` and `squashfs-sysupgrade.bin`. **There is no
factory image** -- the OEM web UI cannot flash this. Install is always:

1. TFTP the initramfs via the U-Boot serial menu (option 1, load to SDRAM)
2. `sysupgrade` the squashfs image from the running initramfs

`u-boot` and `u-boot-env` are read-only and untouched by sysupgrade, so the U-Boot
TFTP path always remains available as recovery regardless of kernel/UBI state.

## What the patches do

**0001 — `kernel: net: dsa: two fixes found bringing up a nested DSA tree`**

Adds `target/linux/generic/pending-6.18/770-net-dsa-disable-checksum-offload-on-nested-conduit.patch`.

The ER-10X has an RTL8367S cascaded behind the MT7621's MT7530, which requires
*nested* DSA trees (`tag_mtk` carries no switch-id field, so one tree cannot
address two switches). The MT7621 MAC's TX checksum engine cannot parse the
doubly-tagged frames that produces. Symptom is distinctive: ping works,
pass-through routing works, but **every TCP connection to or from the board** over
the affected ports hangs -- forwarded traffic already carries a complete checksum
and ICMP is checksummed in software, which hides it.

The fix strips checksum/TSO offload from a conduit that is *itself* a DSA user
port. It must be done on the conduit, never on the inner tree's user ports: those
are bridge members, and a bridge advertises the *intersection* of its members'
features, so clearing them there strips offload from `br-lan` as well. A blanket
`ethtool -K dsa tx off` also works but costs ~46% of egress throughput.

**0002 — `ramips: add support for Ubiquiti EdgeRouter 10X`**

Board DTS, image recipe, network/LED/upgrade glue. Notable points:

- **Ten ports come up as `eth0`-`eth9`** matching the case numbering. The RTL8367
  ports must *not* take `ethN` DSA `label`s -- DSA uses `label` as the netdev name
  at registration, while the MT7530's ports still hold provisional kernel names
  `eth1`-`eth5`, so asking for `eth5` yields
  `cascade: error -17 registering interface eth5` and that port is then *silently
  absent*. Labels are `rtl0`..`rtl4` with `openwrt,netdev-name` for the real names.
- **`rgmii2` pads must be freed to GPIO.** `mt7621.dtsi` puts `<&rgmii2_pins>` in
  the *ethernet controller's* `pinctrl-0`, so disabling `&gmac1` alone does not
  release them.
- **Front panel LED is one two-colour package, both active low**: GPIO13 = white,
  GPIO16 = blue. Both sit in the `jtag` pin group (13-17), which comes up
  MUX UNCLAIMED -- driving them does nothing until that group is claimed as GPIO
  in `&state_default`. An init script holds the boot blink until `br-lan` has
  carrier, because diag.sh's "done" fires ~30s before the DSA links settle.
- **The `factory` partition is deliberately writable.** Stock keeps two 3 MiB
  kernel slots selected by a byte at `factory+0xa0`; OpenWrt spans both with one
  6 MiB kernel at 0x140000. Setting that byte to 0x01 makes U-Boot try Kernel2,
  report `Bad Magic Number`, scan to end of flash and hang with no output. EdgeOS
  alternates slots on its own upgrades, so sysupgrade must be able to reset it.
- NAND needs `412-mtd-rawnand-mt7621-soft-waitrdy.patch` (stuck ready signal).
  `mtk_bmt` is **not** required -- stock uses plain UBI and handles its bad PEBs.
- LAN defaults to **DHCP**: the board has no RTC, so it needs a gateway and
  resolver to fix its clock at all. `sysntpd` resolves its pool hostnames once at
  startup, before the lease lands, and never retries -- hence the
  `hotplug.d/iface` hook that restarts it on ifup. Test from a cold boot; a manual
  `sysntpd restart` hides this.
- `dnsmasq` and `odhcpd-ipv6only` are removed from the image. The package is
  `odhcpd-ipv6only`, not `odhcpd`.

## Not included / known gaps

- No site configuration. Ships stock defaults on DHCP.
- Root password is empty (OpenWrt default).
- **Intermittent fault on the development unit, most likely hardware.** MT7530
  port 0 occasionally stops forwarding to the CPU: `eth0` carrier up at 1G, brport
  state 3, hardware RX counter climbing, but `tcpdump -i eth0` sees nothing and the
  board cannot reach its gateway, while the cascade path keeps working. A reboot
  clears it. Seen twice, on one board.

  The probable cause is **physical damage to that port on this specific unit** --
  it is not a known defect of the design, and it has not been reproduced on any
  other hardware. It also predates the LED/pinmux work, so it is not attributable
  to that.

  Recorded here only so that anyone hitting the same signature can recognise it
  rather than chase it through the driver. Treat it as *unconfirmed*: if you see
  it on a second unit it would be worth investigating properly, but there is no
  present reason to expect it.
- Do not enable kernel STP on `br-lan`: 34s per port to reach forwarding, and
  OpenWrt's br-lan priority of 32767 is one *below* the 32768 switches use, so
  STP-on makes this leaf appliance the LAN's root bridge. `priority=61440` is set
  in uci-defaults so enabling it from LuCI behaves. For loop protection use RSTP
  via mstpd.
- Never dump the whole RTL8367 regmap
  (`/sys/kernel/debug/regmap/mdio-bus:1d/registers`) -- it wedges the switch and
  needs a physical power cycle.

All register values and pin mappings were determined by probing live hardware.

# Known issue: wifi broken after macOS 26 -> 27 upgrade

As of 2026-09-18, wifi is down on both Asahi hosts (`bookpro14-m1-pro`,
`studio-m1-max`). Root cause is **not** in this flake.

`dmesg | grep -i brcmfmac` shows the BCM4387 wifi chip's own firmware
crashing during PCIe setup:

```
brcmf_pcie_setup: Dongle setup failed
... THREADX TRAP INFO ... TRAP 4(930ec0) ...
RO overwritten  12c43d   (repeated)
brcmf_pcie_remove+0x6c/0x140 [brcmfmac]
```

`ip link show` afterward has no wifi interface at all (loopback only) - the
driver never gets far enough to create one.

This started right after the affected machine took a macOS 26 -> 27 upgrade.
Apple Silicon peripheral init (PCIe/coprocessor bring-up, including this wifi
chip) is part of System Firmware, which major macOS upgrades routinely
change. The `nixos-apple-silicon` kernel/m1n1 pairing pinned here predates
that change and doesn't know how to bring the chip up under it.

**Already ruled out, don't re-chase these:**
- The `nixpkgs` flake update around the same time (NetworkManager 1.58.0 ->
  1.58.1) - unrelated, confirmed by content-diffing every wifi-relevant
  package/module between the known-good and broken nixpkgs revisions.
- Pinning `nixos-apple-silicon` back a few revisions - no effect; its repo
  (and the self-contained `linux-asahi` kernel source it pulls from
  AsahiLinux/linux) didn't change in the relevant window anyway.
- Stale extracted peripheral firmware - re-ran the Asahi installer's
  `v: Rebuild vendor firmware package` option to refresh
  `/boot/vendorfw/firmware.cpio` from the current macOS install. Same crash
  afterward, byte-for-byte.

**Actual fix:** needs an `nixos-apple-silicon` update with kernel/m1n1
support for macOS 27's System Firmware. Check upstream
(github.com/nix-community/nixos-apple-silicon, Asahi Linux's own
tracker/Discord) for a BCM4387 + macOS 27 compatibility report before
spending more time on this locally.

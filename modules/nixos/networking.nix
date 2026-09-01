_: {
  networking.networkmanager.enable = true;
  # Per-chip workarounds stay with the host that has the chip: framework13's
  # MT7925 powersave opt-out is in its own default.nix, and the Asahi hosts
  # pick their Broadcom-compatible backend in hosts/asahi-common.nix.
}

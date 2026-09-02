# dotfiles

Unified Nix flake for NixOS (incl. Asahi/Apple Silicon) and macOS.

## Apply

Each config is named after its hostname, so the rebuild tools pick the right
one on their own. `nh` sets `NH_FLAKE` to this repo, so it needs no `--flake`:

    nh os switch          # NixOS, incl. Asahi
    nh darwin switch      # macOS

It wraps the native tools with a `nix-output-monitor` build tree and an `nvd`
diff between generations. Those tools still work directly, and are what you
need on a machine where home-manager hasn't activated yet:

    sudo nixos-rebuild switch --flake ~/.dotfiles     # NixOS, incl. Asahi
    sudo darwin-rebuild switch --flake ~/.dotfiles    # macOS

Append `#<hostname>` to build a different machine's config than the one you're
sitting at.

## Hosts

Six machines, eight configs: the two Apple Silicon Macs dual-boot macOS and
Asahi NixOS. The two Raspberry Pis are single-purpose appliances with no
desktop session and no home-manager profile at all - see
`hosts/raspberrypi-common.nix`.

| Machine        | macOS                 | Linux                   |
| -------------- | --------------------- | ----------------------- |
| Framework 13   | —                     | `framework13-amd-ryzen` |
| MacBook Pro 14 | `macbookpro14-m1-pro` | `bookpro14-m1-pro`      |
| Mac Studio     | `macstudio-m1-max`    | `studio-m1-max`         |
| MacBook Pro 16 | `macbookpro16-m5`     | —                       |
| Raspberry Pi 4 | —                     | `pi-hole`               |
| Raspberry Pi 4 | —                     | `pi-nas`                |

### First activation on a new Mac

`darwin-rebuild` doesn't exist yet before nix-darwin has installed itself:

```
sudo nix --extra-experimental-features "nix-command flakes" run nix-darwin -- switch --flake ~/.dotfiles#<hostname>
```

### First activation on a new Asahi machine

There's no already-booted OS to run `nixos-rebuild` against yet. Install via
[nixos-apple-silicon](https://github.com/nix-community/nixos-apple-silicon)'s
`docs/uefi-standalone.md` guide: bootstrap a UEFI environment with the Asahi
installer, build and boot that project's NixOS installer ISO
(`nix build .#installer-bootstrap`), then partition and install. Copy the
installer's generated `hardware-configuration.nix` into this repo's
`hosts/<hostname>/` before the first `nixos-rebuild switch`.

### First activation on a new Raspberry Pi

Like Asahi, there's no already-booted OS to run `nixos-rebuild` against. No
monitor or keyboard ever touches the Pi, but unlike the other hosts here,
the actual install runs from an interactive SSH session, not a single
non-interactive command - `nixos-anywhere` was the original plan, but it
doesn't work for this board: kexec isn't supported on the Pi, and the
installer's own root filesystem lives on the same SD card disko would need
to wipe, which corrupts the card mid-install without ever completing (ask
past-me how that went - twice).

1. Clone [nixos-raspberrypi](https://github.com/nvmd/nixos-raspberrypi) and
   edit its `custom-user-config` block in `flake.nix`, replacing both
   `# YOUR SSH PUB KEY HERE #` placeholders (one for `nixos`, one for
   `root`) with your own public key. Build the Pi 4 installer image on an
   `aarch64-linux` box (`bookpro14-m1-pro` or `studio-m1-max` - cross-
   building this from macOS means emulating a kernel build, painfully
   slow):

   ```
   nix --accept-flake-config build .#installerImages.rpi4
   ```

   It's board-specific, not host-specific, so the same image works for
   either Pi's first SD card.
2. Flash the resulting `result/sd-image/*.img.zst` to the SD card (macOS's
   built-in reader is more reliable than Asahi Linux's for this - decompress
   straight into `dd` via `nix run nixpkgs#zstd -- -dc image.img.zst | sudo
   dd of=/dev/rdiskN bs=4m`, using the raw `rdisk` device). Insert it, wire
   up Ethernet, power on, and find its DHCP-assigned IP from your router.
3. SSH in as `root` (the key from step 1) and, in that one session, do two
   things before root access disappears for good on real-config activation
   (`modules/nixos/ssh.nix` sets `PermitRootLogin = "no"` unconditionally):

   ```
   mkdir -p /home/anders/.ssh && chmod 700 /home/anders/.ssh
   echo '<your pubkey>' > /home/anders/.ssh/authorized_keys
   chmod 600 /home/anders/.ssh/authorized_keys
   passwd anders
   ```

   Remember that password - `security.sudo.wheelNeedsPassword = false` (set
   in `hosts/raspberrypi-common.nix`, precisely because these boxes have no
   console to type a password at) only takes effect once the real config
   has already been deployed once, so the first deploy needs a real one.
4. Copy this repo onto the Pi and build+activate *locally there*, not via
   `--target-host` from another machine:

   ```
   rsync -av ~/.dotfiles/ anders@<pi-ip>:~/.dotfiles/
   ssh anders@<pi-ip>
   cd ~/.dotfiles && sudo nixos-rebuild switch --flake .#pi-hole   # or #pi-nas
   ```

   `--target-host` builds elsewhere and copies the closure over as the SSH
   user; that copy gets refused ("lacks a signature by a trusted key")
   because `anders` isn't in `nix.settings.trusted-users` on a fresh
   install, and root SSH is gone by this point anyway. Building locally
   sidesteps both problems - the same rsync-and-switch dance is also just
   how you deploy *updates* to these two hosts going forward.
5. After the first successful switch, immediately fix the one thing that
   pre-existed the real user: `chown -R anders:users /home/anders/.ssh` -
   NixOS's user-creation activation chowns the home directory it creates,
   but not a `.ssh` you seeded into it beforehand, and sshd's strict-mode
   checks reject the mismatch for a non-root user. (Root-owned would be
   fine per sshd's own rules; empirically it wasn't, so just fix it.)

No `hardware-configuration.nix` to copy back afterward for either host:
`raspberry-pi-4.base` and the plain `fileSystems` entries in each host's
`default.nix` (by label - `FIRMWARE`, `NIXOS_SD` - matching how
nixos-raspberrypi's sd-image is already partitioned) own everything that
file would otherwise carry. `pi-nas`'s external SSD is the one place disko
still applies, since it's a genuinely blank second disk, not the one the
installer is booted from.

## Updating inputs

`nix flake update` bumps every pinned input.

## Development

    nix fmt          # nixfmt, deadnix and statix over every .nix file
    nix flake check  # formatting, secret scan, and every host evaluates
    direnv allow     # once per checkout; installs the pre-commit hooks

CI runs the same `nix flake check` plus an evaluation of all eight host
configurations on every push and pull request.

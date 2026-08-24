# dotfiles

Unified Nix flake for NixOS (incl. Asahi/Apple Silicon) and macOS.

## Apply

| Host | Kind | Command |
|---|---|---|
| `framework13-amd-ryzen` | NixOS | `sudo nixos-rebuild switch --flake ~/.dotfiles#framework13-amd-ryzen` |
| `bookpro14-m1-pro` | Asahi NixOS | `sudo nixos-rebuild switch --flake ~/.dotfiles#bookpro14-m1-pro` |
| `studio-m1-max` | Asahi NixOS | `sudo nixos-rebuild switch --flake ~/.dotfiles#studio-m1-max` |
| `macbookpro14-m1-pro` | darwin | `darwin-rebuild switch --flake ~/.dotfiles#macbookpro14-m1-pro` |
| `macbookpro16-m5` | darwin | `darwin-rebuild switch --flake ~/.dotfiles#macbookpro16-m5` |
| `macstudio-m1-max` | darwin | `darwin-rebuild switch --flake ~/.dotfiles#macstudio-m1-max` |

`nixos-rebuild`/`darwin-rebuild` also auto-select the right output by
hostname when given a bare `--flake ~/.dotfiles` (no `#attr`) — the explicit
form above is what's documented since it needs no prior setup.

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
`hosts/<hostname>/` before the first `nixos-rebuild switch` from the table
above.

## Updating inputs

`nix flake update` bumps every pinned input.

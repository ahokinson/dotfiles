# dotfiles

Unified Nix flake for NixOS, macOS (Apple Silicon), and Asahi Fedora.

## Apply

| Host | Kind | Command |
|---|---|---|
| `framework13-amd-ryzen` | NixOS | `sudo nixos-rebuild switch --flake ~/.dotfiles#framework13-amd-ryzen` |
| `macbookpro14-m1-pro` | darwin | `darwin-rebuild switch --flake ~/.dotfiles#macbookpro14-m1-pro` |
| `macbookpro16-m5` | darwin | `darwin-rebuild switch --flake ~/.dotfiles#macbookpro16-m5` |
| `macstudio-m1-max` | darwin | `darwin-rebuild switch --flake ~/.dotfiles#macstudio-m1-max` |
| `bookpro14-m1-pro` | Asahi Fedora | `NIX_CONFIG="experimental-features = nix-command flakes" nix run github:nix-community/home-manager -- switch -b hm-backup --flake ~/.dotfiles#bookpro14-m1-pro` |
| `studio-m1-max` | Asahi Fedora | `NIX_CONFIG="experimental-features = nix-command flakes" nix run github:nix-community/home-manager -- switch -b hm-backup --flake ~/.dotfiles#studio-m1-max` |

`nixos-rebuild`/`darwin-rebuild` also auto-select the right output by
hostname when given a bare `--flake ~/.dotfiles` (no `#attr`) — the explicit
form above is what's documented since it needs no prior setup.

### First activation on a new Mac

`darwin-rebuild` doesn't exist yet before nix-darwin has installed itself:

```
sudo nix --extra-experimental-features "nix-command flakes" run nix-darwin -- switch --flake ~/.dotfiles#<hostname>
```

### First activation on a new Asahi machine

A fresh install's stock Nix hasn't got flakes enabled yet, and the `-b`
backup flag is required since a standalone `homeManagerConfiguration` has no
`home.backupFileExtension` equivalent — both already covered by the commands
above.

COSMIC itself must be installed at the OS level via `dnf` first — this repo
only manages `$HOME`, not Fedora's package set. Confirm the exact
package/group name against what's actually available in Fedora Asahi
Remix's repos before running the command above.

## Updating inputs

`nix flake update` bumps every pinned input.

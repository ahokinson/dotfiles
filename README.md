# dotfiles

Unified Nix flake for NixOS (incl. Asahi/Apple Silicon) and macOS.

## Apply

Each config is named after its hostname, so the rebuild tools pick the right
one on their own. `nh` sets `NH_FLAKE` to this repo, so it needs no `--flake`:

    nh os switch          # NixOS, incl. Asahi
    nh darwin switch      # macOS

It wraps the native tools with a `nix-output-monitor` build tree and an `nvd`
diff of what actually changed. Those tools still work directly, and are what
you need on a machine where home-manager hasn't activated yet:

    sudo nixos-rebuild switch --flake ~/.dotfiles     # NixOS, incl. Asahi
    sudo darwin-rebuild switch --flake ~/.dotfiles    # macOS

Append `#<hostname>` to build a different machine's config than the one you're
sitting at.

## Hosts

Four machines, six configs — the two Apple Silicon Macs dual-boot macOS and
Asahi NixOS.

| Machine        | macOS                 | Linux                   |
| -------------- | --------------------- | ----------------------- |
| Framework 13   | —                     | `framework13-amd-ryzen` |
| MacBook Pro 14 | `macbookpro14-m1-pro` | `bookpro14-m1-pro`      |
| Mac Studio     | `macstudio-m1-max`    | `studio-m1-max`         |
| MacBook Pro 16 | `macbookpro16-m5`     | —                       |

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

## Updating inputs

`nix flake update` bumps every pinned input.

## Development

    nix fmt          # nixfmt, deadnix and statix over every .nix file
    nix flake check  # formatting, secret scan, and every host evaluates
    direnv allow     # once per checkout; installs the pre-commit hooks

CI runs the same `nix flake check` plus an evaluation of all six host
configurations on every push and pull request.

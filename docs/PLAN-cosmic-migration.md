# Switch framework13-amd-ryzen from KDE Plasma to COSMIC

## Context

Goal: a NixOS desktop that looks and feels more like macOS. This repo already has a
deliberate, multi-commit effort in that direction on KDE Plasma 6 — `home/linux/plasma-panel.nix`
builds a bottom floating autohide dock mirroring `modules/darwin/system.nix`'s
`system.defaults.dock.*` (same two pinned apps, documented tilesize↔height math), a
menu-bar-style clock, Catppuccin Frappe throughout, and a re-skinned SDDM greeter.

The decision is to stop hand-faking the macOS shell on Plasma and move to COSMIC, which ships
a top panel + dock natively. COSMIC reached stable 1.0 in Dec 2025 (1.0.13/1.1 as of Aug 2026)
and has had a first-party NixOS module since 25.05.

Constraints:

- `framework13-amd-ryzen` is the **only** NixOS host and a daily-driver laptop. Every change
  must be revertible without a working desktop.
- Two Asahi Fedora machines run standalone home-manager (`asahiHome` in `flake.nix`) and share
  `home/linux/plasma-panel.nix` + `plasma-theme.nix`. **They stay on Plasma, untouched.**
- Real macOS *visual* parity (icons, cursors, window chrome) doesn't exist in the repo yet and
  is independent of this DE switch — Phase 2 below.

## Step 0 — commit the pending WIP first

The tree had unrelated uncommitted work when this plan was written. Commit it separately so
the COSMIC diff stays readable. Suggested messages (bare imperative subject, repo style, **no
trailers**):

```
Disable MT7925 wifi powersave to fix suspend drops   # modules/nixos/networking.nix
Add brlaser driver and Avahi mDNS printer discovery  # modules/nixos/audio-printing.nix
Codesign reliquary on darwin so Keychain ACLs survive upgrades
                                                     # home/darwin/reliquary-codesign.nix + default.nix
Relock flake inputs                                  # flake.lock
```

Then branch for the COSMIC work.

## Verified facts (already checked — don't re-derive)

- `services.desktopManager.cosmic.enable` exists in nixpkgs unstable. `xwayland.enable`
  defaults to **true** → `services.xserver.enable = true` is **not** needed; drop it.
- The COSMIC NixOS module already enables `graphical-desktop`, `dconf`, `polkit`, `rtkit`,
  `accounts-daemon`, `libinput`, `upower`, `geoclue2`, XDG portals (cosmic + gtk), and
  mkDefaults Bluetooth / NetworkManager / GVFS / gnome-keyring / power-profiles-daemon.
- The COSMIC module does **not** enable `fwupd`. The `fwupd-refresh` polkit-ordering
  workaround in today's `desktop.nix` exists because *Plasma* defaulted it on. Framework
  hardware genuinely wants fwupd for BIOS/EC updates → set it explicitly and keep the fix.
- **`cosmic-manager` exports `homeManagerModules.cosmic-manager`** (verified against its
  `flake.nix`) — *not* `homeModules.*`. Its option namespace is `wayland.desktopManager.cosmic.*`,
  with `.appearance.theme` confirmed. **Panel / dock / wallpaper option paths are NOT
  confirmed** — read its `./modules` tree before writing those files. Do not guess syntax.
- `catppuccin/nix` (pinned rev `35d78c2`) has **no** COSMIC module. `catppuccin/cosmic-desktop`
  exists but ships theme files meant for import via COSMIC Settings (`themes/cosmic-settings/`),
  with no Nix flake or package. Wiring it declaratively needs the on-disk config path/format
  verified first.

## Boundary map (shared vs. host-only)

`home/linux/default.nix` imports only DE-agnostic files: `packages.nix`, `catppuccin.nix`,
`wallpaper.nix`, `zen-browser.nix`, `desktop-file-trust.nix`. All stay.

Plasma files are imported explicitly, not via `default.nix`:

| File | NixOS host | Asahi |
|---|---|---|
| `plasma-panel.nix`, `plasma-theme.nix` | yes | yes — **keep** |
| `plasma.nix`, `catppuccin-qt.nix` | yes | no |

So only the NixOS host's import list changes. `asahiHome` in `flake.nix` is never edited.

Gotcha: `home/linux/wallpaper.nix` sits in the "shared" set but shells out to
`plasma-apply-wallpaperimage` guarded by `command -v`. Under COSMIC that binary is absent so it
silently no-ops — harmless, no edit needed, but the host needs its own COSMIC wallpaper setter.

Grep confirms `security.nix`, `audio-printing.nix`, `base.nix` have **zero** Plasma/SDDM/KDE
references. Only `desktop.nix` and `user.nix` (which installs `kdePackages.kate`) do.

## Changes

### 1. `flake.nix` — add input

Mirror the existing `plasma-manager` input:

```nix
cosmic-manager = {
  url = "github:HeitorAugustoLN/cosmic-manager";
  inputs.nixpkgs.follows = "nixpkgs";
  inputs.home-manager.follows = "home-manager";
};
```

`asahiHome`, `homeConfigurations`, and all `darwinConfigurations` unchanged.

### 2. `git mv modules/nixos/desktop.nix modules/nixos/desktop-plasma.nix`

Content preserved verbatim. Stays a valid module, just unimported — this is what makes the
revert a one-line edit instead of git archaeology.

### 3. `modules/nixos/desktop-cosmic.nix` (new)

```nix
services.desktopManager.cosmic.enable = true;
services.displayManager.cosmic-greeter.enable = true;
```

Carry forward from the old module:

- `services.fwupd.enable = true;` — now explicit, plus the existing
  `systemd.services.fwupd-refresh.{after,wants} = [ "polkit.service" ]` fix. Keep the comment
  but reword: the cause is no longer "Plasma pulls in fwupd".
- **Drop** `services.xserver.enable` (XWayland on by default).
- **Drop** the `qt.platformTheme = "kde"` block, the SDDM `breezeFrappe` derivation, and the
  `systemd.tmpfiles` kdeglobals symlink — all Plasma/SDDM-specific. Neither pinned app (Zen,
  Ghostty) is a themed Qt app, so losing Kvantum styling costs nothing visible here. Revisit
  as a phase-1.5 refinement if some Qt app looks wrong.

### 4. `hosts/framework13-amd-ryzen/default.nix` — two hunks

Line 15: `modules/nixos/desktop.nix` → `modules/nixos/desktop-cosmic.nix`

Lines 36–40: replace the Plasma block

```nix
(selfPath "home/linux/catppuccin-qt.nix")
inputs.plasma-manager.homeModules.plasma-manager
(selfPath "home/linux/plasma-panel.nix")
(selfPath "home/linux/plasma-theme.nix")
(selfPath "home/linux/plasma.nix")
```

with

```nix
inputs.cosmic-manager.homeManagerModules.cosmic-manager
(selfPath "home/linux/cosmic/panel.nix")
(selfPath "home/linux/cosmic/theme.nix")
(selfPath "home/linux/cosmic/wallpaper.nix")
```

`(selfPath "home/linux")` stays. Reverting these hunks + the line-15 import is the complete undo.

### 5. `home/linux/cosmic/panel.nix` (new, host-only)

Panel + dock via `cosmic-manager`. Mirror the intent documented in `plasma-panel.nix`: bottom
dock, autohide, icon size matched to darwin's `dock.tilesize = 32`, same two pinned apps
(`zen-beta.desktop`, `com.mitchellh.ghostty.desktop`). COSMIC's default top-panel + dock split
moves the clock/tray to the top panel — that's the point of the switch, so let COSMIC's
defaults do that work and override only what differs from macOS.

**Verify `cosmic-manager`'s actual panel/dock option paths before writing this file.**

### 6. `home/linux/cosmic/theme.nix` (new, host-only)

Dark mode + Catppuccin Frappe + fonts from `home/common/fonts.nix` (`sharedFonts.generalFamily`,
`pointSize`) via `wayland.desktopManager.cosmic.appearance.theme`.

Since `catppuccin/nix` has no COSMIC module, the fallback is consuming
`catppuccin/cosmic-desktop`'s generated theme files via `pkgs.fetchFromGitHub` +
`xdg.configFile` — the pattern `home/linux/kvantum-asahi.nix` already uses for Kvantum. Verify
COSMIC's on-disk theme config path and format first.

### 7. `home/linux/cosmic/wallpaper.nix` (new, host-only)

Same asset as today: `home/common/_files/wallpaper-frappe-base.png` (`#303446`). Prefer a
`cosmic-manager` wallpaper option; fall back to writing `cosmic-bg`'s config directly. Carry
over the caution in `plasma.nix`'s header about needing a live session rather than a
system-activation hook.

### 8. Optional: `home/common/dock-apps.nix` (new)

The pinned-app list is hand-written in two places today (`modules/darwin/system.nix` as `.app`
paths, `home/linux/plasma-panel.nix` as `.desktop` ids). COSMIC makes it a third copy in a
third identifier format. Extract to one source:

```nix
{
  zen     = { darwinApp = "Zen Browser (Beta).app"; linuxDesktopId = "zen-beta.desktop"; };
  ghostty = { darwinApp = "Ghostty.app";            linuxDesktopId = "com.mitchellh.ghostty.desktop"; };
}
```

Mechanical edits to darwin + plasma-panel, no behavior change. Fine as a separate follow-up
commit if you want the DE switch to stay minimal.

### 9. Cheap touch-ups

- `home/common/fonts.nix` docstring names `home/linux/plasma.nix` as a consumer — add the
  COSMIC files or it goes stale.
- `modules/nixos/user.nix` installs `kdePackages.kate`. Runs fine under any Wayland compositor,
  so this is a keep-or-drop call, not a blocker.

### Untouched

`security.nix`, `audio-printing.nix`, `base.nix`, `home/linux/default.nix`, `packages.nix`,
`catppuccin.nix`, `zen-browser.nix`, `desktop-file-trust.nix`, everything under
`modules/darwin/`, and `asahiHome`.

## Verification / rollout

Order matters — this is the only NixOS box.

1. Commit the WIP (Step 0), then branch.
2. `nixos-rebuild build-vm --flake ~/.dotfiles#framework13-amd-ryzen` — run directly, since
   `switch.zsh` has no VM mode (its `build`/`dry`/`switch` map to `nixos-rebuild`
   `build`/`dry-build`/`switch`). Boot the QEMU image: confirm cosmic-greeter appears, session
   starts, panel/dock/wallpaper/theme render. Won't exercise real AMD GPU accel or
   Framework-specific hardware, but does evaluate the identical `nixosConfiguration` including
   the home-manager module.
3. `./switch.zsh build` on the real host — catches eval/build errors with zero risk to the
   running session.
4. `./switch.zsh` to activate. Reboot into COSMIC.
5. Rollback has two independent paths: pick the previous generation from systemd-boot (capped
   by `boot.loader.systemd-boot.configurationLimit` in `boot.nix`), or revert the three hunks
   in `hosts/framework13-amd-ryzen/default.nix` and re-switch.
6. Once settled, decide whether `desktop-plasma.nix` stays as inert reference or gets deleted.
   `plasma-panel.nix` / `plasma-theme.nix` never become dead — Asahi still imports them.

**All `switch.zsh` / `nixos-rebuild` invocations are run by the user, not by Claude.**

## Phase 2 (separate commit, DE-independent)

Actual macOS visual parity, which neither Plasma nor COSMIC gives for free:
`whitesur-icon-theme`, `whitesur-cursors`, `whitesur-gtk-theme` (all in nixpkgs by-name, none
currently used — today's theming is Catppuccin *color* only). Wires in via home-manager's
`gtk.iconTheme` / `gtk.cursorTheme` / `gtk.theme`, the mechanism `home/linux/catppuccin.nix`
already uses, or COSMIC's native appearance settings if it doesn't defer to GTK icon lookup.

Note this conflicts aesthetically with Catppuccin — WhiteSur is macOS light/dark grey, not
Frappe pastel. Decide whether the target is "macOS" or "Catppuccin" before doing it.

## Unknowns to verify during implementation (do not guess)

- `cosmic-manager`'s panel / dock / wallpaper option paths (read its `./modules` tree).
- COSMIC's on-disk theme config path + format for the `catppuccin/cosmic-desktop` fallback.
- Whether `cosmic-manager` exposes a font option or fonts route through the theme block.
- Whether `cosmic-bg` needs a live session to pick up wallpaper changes.

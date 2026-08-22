#!/usr/bin/env zsh
# switch.zsh — autodetect the host and apply the matching flake output.
#
# Usage:
#   ./switch.zsh                      Auto-detect and switch
#   ./switch.zsh switch               (same as above)
#   ./switch.zsh build                Build only (no activation)
#   ./switch.zsh dry                  Dry-run / print what would change
#   ./switch.zsh list                 Show detected host info + available outputs
#   ./switch.zsh check                Compare pinned flake inputs against upstream
#   ./switch.zsh <explicit-output>    Override auto-detection
#
# macOS detection matches the current hostname against known darwin hosts
# (hw.model is only a sanity cross-check, never the deciding signal). A
# brand-new, never-activated Mac has no matching hostname yet — pass the
# output explicitly for that first run.

set -euo pipefail

zmodload zsh/datetime
autoload -U colors && colors

readonly DOTFILES=${0:A:h}
cd "$DOTFILES"

for f in "$DOTFILES"/switch.d/*.zsh; do
  source "$f"
done

main "$@"

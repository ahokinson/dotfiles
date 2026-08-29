# Vesktop (Discord via Vencord), themed Catppuccin Frappe via the official
# catppuccin/nix module riding home-manager's own programs.vesktop. The
# global catppuccin.enable/flavor/accent toggle lives in
# home/common/catppuccin.nix; this just opts vesktop into it.
_: {
  catppuccin.vesktop.enable = true;

  programs.vesktop = {
    enable = true;

    # No titlebar, no window controls, full space for Discord - COSMIC's own
    # keybinds cover what the controls used to (Super+Q/Alt+F4 close,
    # Super+M maximize, Super+drag anywhere to move; nothing default for
    # minimize).
    #
    # Two separate settings stores, confirmed in Vesktop's own main.js:
    # `frame: store.customTitleBar !== true` (Vesktop's own settings.json -
    # this option) drops the native frame in favor of a title bar Discord's
    # web content draws itself; `frameless` (Vencord's settings.json, below)
    # drops it with no replacement drawn at all. customTitleBar stays false
    # so only frameless's frame:false takes effect.
    settings.customTitleBar = false;

    vencord.settings.frameless = true;
  };
}

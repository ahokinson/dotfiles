# Vesktop (Discord via Vencord), themed Catppuccin Frappe via the official
# catppuccin/nix module riding home-manager's own programs.vesktop. The
# global catppuccin.enable/flavor/accent toggle lives in
# home/common/catppuccin.nix; this just opts vesktop into it.
_: {
  catppuccin.vesktop.enable = true;

  programs.vesktop = {
    enable = true;

    # Without this, Vesktop's BrowserWindow is created with frame:true and
    # gets whatever native decoration the platform draws - COSMIC's own
    # server-side chrome on Linux, unstyled and inconsistent with everything
    # else here. customTitleBar:true (confirmed in Vesktop's own main.js:
    # `frame: store.customTitleBar !== true`) makes it frame:false instead
    # and draw Discord's own title bar in its web content, which the
    # catppuccin.vesktop theme above already covers.
    settings.customTitleBar = true;
  };
}

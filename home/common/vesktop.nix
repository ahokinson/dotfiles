# The global catppuccin toggle is in home/common/catppuccin.nix; this opts
# vesktop into it.
_: {
  catppuccin.vesktop.enable = true;

  programs.vesktop = {
    enable = true;

    # No titlebar or window controls; COSMIC keybinds replace them
    # (home/linux/cosmic/shortcuts.nix).
    #
    # Two settings stores, per Vesktop's main.js. This one gives
    # `frame: store.customTitleBar !== true`, dropping the native frame in
    # favor of one Discord's web content draws; `frameless` below drops it
    # with nothing in its place. Left false so only frameless applies.
    settings.customTitleBar = false;

    vencord.settings.frameless = true;
  };
}

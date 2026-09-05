# Whether this NixOS host is Apple Silicon hardware running Asahi, as
# opposed to framework13-amd-ryzen.
{ osConfig ? null }: osConfig.hardware.asahi.enable or false

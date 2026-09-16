# COSMIC's Power applet opens a lock/logout/restart/shutdown menu; wlogout
# is the wlroots-ecosystem equivalent, opened from waybar.nix's power icon.
# No suspend entry - matches idle.nix's never-suspend policy.
{ pkgs, ... }:
{
  programs.wlogout = {
    enable = true;
    layout = [
      {
        label = "lock";
        text = "Lock";
        keybind = "l";
        action = "loginctl lock-session";
      }
      {
        label = "logout";
        text = "Log out";
        keybind = "e";
        action = "swaymsg exit";
      }
      {
        label = "reboot";
        text = "Reboot";
        keybind = "r";
        action = "systemctl reboot";
      }
      {
        label = "shutdown";
        text = "Shutdown";
        keybind = "s";
        action = "systemctl poweroff";
      }
    ];

    # Vendored from wlogout 1.2.2's packaged default style.css - setting
    # `style` replaces it wholesale rather than layering on top, so this
    # stays a full copy, not a partial override. Only change from upstream:
    # window/button background alpha (0.867, matching fuzzel's own shipped
    # alpha) and icon paths rewritten through ${pkgs.wlogout} the same way
    # nixpkgs' own postPatch rewrites /usr/share/wlogout -> $out/share/wlogout.
    # Re-diff against upstream on a wlogout version bump.
    style = ''
      * {
      	background-image: none;
      	box-shadow: none;
      }

      window {
      	background-color: rgba(12, 12, 12, 0.867);
      }

      button {
          border-radius: 0;
          border-color: black;
      	text-decoration-color: #FFFFFF;
          color: #FFFFFF;
      	background-color: rgba(30, 30, 30, 0.867);
      	border-style: solid;
      	border-width: 1px;
      	background-repeat: no-repeat;
      	background-position: center;
      	background-size: 25%;
      }

      button:focus, button:active, button:hover {
      	background-color: #3700B3;
      	outline-style: none;
      }

      #lock {
          background-image: image(url("${pkgs.wlogout}/share/wlogout/icons/lock.png"));
      }
      #logout {
          background-image: image(url("${pkgs.wlogout}/share/wlogout/icons/logout.png"));
      }
      #suspend {
          background-image: image(url("${pkgs.wlogout}/share/wlogout/icons/suspend.png"));
      }
      #hibernate {
          background-image: image(url("${pkgs.wlogout}/share/wlogout/icons/hibernate.png"));
      }
      #shutdown {
          background-image: image(url("${pkgs.wlogout}/share/wlogout/icons/shutdown.png"));
      }
      #reboot {
          background-image: image(url("${pkgs.wlogout}/share/wlogout/icons/reboot.png"));
      }
    '';
  };
}

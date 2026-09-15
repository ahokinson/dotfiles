{ prev }:
import ./applets.nix { inherit prev; } // import ./workspaces.nix { inherit prev; }

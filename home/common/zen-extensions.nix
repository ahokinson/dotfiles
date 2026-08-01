# Force-installs extensions via distribution/policies.json, independent of
# any profile - safe under the profile-ownership constraint in
# zen-settings.nix. Only imported where inputs.zen-browser.homeModules.beta
# is present (home/darwin/zen-browser.nix, home/linux/zen-browser.nix);
# the option doesn't exist under NixOS's plain nixpkgs zen-browser package.
{ ... }: {
  programs.zen-browser.policies.ExtensionSettings =
    builtins.mapAttrs (_: slug: {
      install_url = "https://addons.mozilla.org/firefox/downloads/latest/${slug}/latest.xpi";
      installation_mode = "force_installed";
    }) {
      "adnauseam@rednoise.org" = "adnauseam"; # AdNauseam
      "{d7742d87-e61d-4b78-b8a1-b469842139fa}" = "vimium-ff"; # Vimium
      "{d6f02b92-88b3-4aa5-ba7c-14519042171d}" = "sort-tabs-advanced"; # Sort Tabs Advanced
    };
}

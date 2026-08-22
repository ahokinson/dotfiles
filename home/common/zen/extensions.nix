# Force-installs extensions via distribution/policies.json, independent of
# any profile. Only imported where inputs.zen-browser.homeModules.beta is
# present (home/darwin/zen-browser.nix, home/linux/zen-browser.nix) — the
# option doesn't exist under NixOS's plain nixpkgs zen-browser package.
{ ... }: {
  programs.zen-browser.policies.ExtensionSettings =
    builtins.mapAttrs (_: slug: {
      install_url = "https://addons.mozilla.org/firefox/downloads/latest/${slug}/latest.xpi";
      installation_mode = "force_installed";
    }) {
      "adnauseam@rednoise.org" = "adnauseam"; # AdNauseam
      "{3579f63b-d8ee-424f-bbb6-6d0ce3285e6a}" = "chameleon-ext"; # Chameleon
      "{d6f02b92-88b3-4aa5-ba7c-14519042171d}" = "sort-tabs-advanced"; # Sort Tabs Advanced
      "{d7742d87-e61d-4b78-b8a1-b469842139fa}" = "vimium-ff"; # Vimium
      "{aecec67f-0d10-4fa7-b7c7-609a2db280cf}" = "violentmonkey"; # Violentmonkey
    };
}

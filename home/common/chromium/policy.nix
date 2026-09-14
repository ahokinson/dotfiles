# Canonical Chromium managed-policy content, shared by
# modules/nixos/chromium.nix (-> JSON under /etc/chromium/policies/managed/)
# and modules/darwin/system/chromium.nix (-> plist under
# /Library/Managed Preferences/<user>/org.chromium.Chromium.plist). Every key
# here must be valid, and mean the same thing, on both platforms.
{
  # --- Google account / sync ------------------------------------------------
  "SyncDisabled" = true;
  "BrowserSignin" = 0; # 0 = sign-in disabled outright

  # --- Telemetry -------------------------------------------------------------
  "MetricsReportingEnabled" = false;
  "UrlKeyedAnonymizedDataCollectionEnabled" = false;
  "CloudReportingEnabled" = false;

  # --- Safe Browsing -----------------------------------------------------
  # 1 = Standard: still checks against Google's blocklist, skips Enhanced
  # Protection's real-time full-URL/telemetry upload.
  "SafeBrowsingProtectionLevel" = 1;

  # --- Autofill / passwords ---------------------------------------------
  # Mirrors home/common/zen/data.nix's formautofill.{addresses,creditCards}
  # = false and signon.rememberSignons = false.
  "AutofillAddressEnabled" = false;
  "AutofillCreditCardEnabled" = false;
  "PaymentMethodQueryEnabled" = false;
  "PasswordManagerEnabled" = false;
  "ImportAutofillFormData" = false;

  # --- Spelling ----------------------------------------------------------------
  # Cloud spellcheck (uploads text-field contents to Google); local
  # spellcheck is a separate policy, left unset so it still works.
  "SpellCheckServiceEnabled" = false;

  # --- Chrome-the-product nagging -----------------------------------------
  "PromotionsEnabled" = false;
  "DefaultBrowserSettingEnabled" = false;

  # --- Misc, none of it feature-breaking -------------------------------------
  "AlternateErrorPagesEnabled" = false;
  "SearchSuggestEnabled" = false;
  "NetworkPredictionOptions" = 2; # no DNS prefetch/preconnect speculation
  "BackgroundModeEnabled" = false;
  "AllowDeletingBrowserHistory" = true;

  # --- Force-installed extensions -----------------------------------------
  "ExtensionSettings" = {
    # uBlock Origin Lite (gorhill's MV3 successor; classic MV2 uBlock
    # Origin was delisted in 2024 and can no longer be force-installed as
    # of Chrome 151 removing the last MV2 shim).
    "ddkjiahejlhfcafbddmgiahcphecmpfh" = {
      installation_mode = "force_installed";
      update_url = "https://clients2.google.com/service/update2/crx";
    };
  };
}

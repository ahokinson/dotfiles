# nix-darwin system defaults, fonts, and user account.
# Everything that targets a system-wide concern (not a user dotfile) lives here.
{ config, pkgs, selfPath, ... }:
let
  sharedFonts = import (selfPath "home/common/fonts.nix") { inherit pkgs; };
in {
  # Apple Silicon mac
  nixpkgs.hostPlatform = "aarch64-darwin";

  # Required since nix-darwin's multi-user migration: user-scoped
  # system.defaults options (dock, finder, NSGlobalDomain) apply to this user.
  system.primaryUser = "anders";

  # Use the Determinate Nix installer style (handles launchd services).
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = true;
  # Old generations otherwise stack up indefinitely across switches
  # (mirrors nix.gc in modules/nixos/base.nix). `interval` is a list per
  # nix-darwin's launchd StartCalendarInterval type.
  nix.gc = {
    automatic = true;
    interval = [{ Weekday = 0; Hour = 3; Minute = 15; }];
    options = "--delete-older-than 14d";
  };

  # Determinate Nix uses GID 350 for nixbld, not nix-darwin's historical
  # default of 30000. Must match the actual group or activation aborts.
  ids.gids.nixbld = 350;

  # Fonts available to all macOS apps via the system (same list as
  # home-manager's home.packages - see home/common/fonts.nix).
  fonts.packages = sharedFonts.packages;

  # macOS user defaults, set exhaustively so all 3 Macs stay identical
  # (except universalaccess.* - see modules/darwin/universalaccess.nix).
  system.defaults = {
    dock.autohide = true;
    dock.magnification = false;
    # Finder is always pinned by macOS regardless of what's declared here —
    # including it would risk a duplicate icon, so it's omitted.
    dock.persistent-apps = [
      "/Users/anders/Applications/Home Manager Apps/Zen Browser (Beta).app"
      "/Users/anders/Applications/Home Manager Apps/Ghostty.app"
    ];
    dock.wvous-br-corner = 4; # Desktop
    dock.wvous-tr-corner = 2; # Mission Control
    dock.wvous-tl-corner = 13; # Lock Screen
    dock.wvous-bl-corner = 5; # Start Screen Saver
    dock.appswitcher-all-displays = false;
    dock.autohide-delay = 0.24;
    dock.autohide-time-modifier = 1.0;
    dock.dashboard-in-overlay = false;
    dock.enable-spring-load-actions-on-all-items = false;
    dock.expose-animation-duration = 1.0;
    dock.expose-group-apps = false;
    dock.launchanim = true;
    dock.mineffect = "genie";
    dock.minimize-to-application = false;
    dock.mru-spaces = true;
    dock.orientation = "bottom";
    dock.scroll-to-open = false;
    dock.showAppExposeGestureEnabled = false;
    dock.showDesktopGestureEnabled = false;
    dock.showLaunchpadGestureEnabled = false;
    dock.showMissionControlGestureEnabled = false;
    dock.show-process-indicators = true;
    dock.showhidden = false;
    # Recent apps would otherwise show up dynamically next to the pinned
    # list above, defeating the point of pinning it identically everywhere.
    dock.show-recents = false;
    dock.slow-motion-allowed = false;
    dock.static-only = false;
    dock.tilesize = 64;
    dock.largesize = 16;

    # Verified against this machine's actual settings rather than
    # nix-darwin's docs, which claim Clicking/TrackpadRightClick default to
    # false/false and swipescrolldirection defaults to true — all three are
    # wrong here (real values: false/true/false).
    trackpad.Clicking = false;
    trackpad.TrackpadRightClick = true;
    trackpad.Dragging = false;
    trackpad.TrackpadThreeFingerDrag = false;
    trackpad.ActuationStrength = 1;
    trackpad.FirstClickThreshold = 1;
    trackpad.SecondClickThreshold = 1;
    trackpad.TrackpadThreeFingerTapGesture = 2;
    trackpad.ActuateDetents = true;
    trackpad.DragLock = false;
    trackpad.ForceSuppressed = false;
    trackpad.TrackpadCornerSecondaryClick = 0;
    trackpad.TrackpadFourFingerHorizSwipeGesture = 0;
    trackpad.TrackpadFourFingerPinchGesture = 0;
    trackpad.TrackpadFourFingerVertSwipeGesture = 2;
    trackpad.TrackpadMomentumScroll = true;
    trackpad.TrackpadPinch = false;
    trackpad.TrackpadRotate = false;
    trackpad.TrackpadThreeFingerHorizSwipeGesture = 2;
    trackpad.TrackpadThreeFingerVertSwipeGesture = 2;
    trackpad.TrackpadTwoFingerDoubleTapGesture = false;
    trackpad.TrackpadTwoFingerFromRightEdgeSwipeGesture = 0;

    NSGlobalDomain.AppleShowAllExtensions = true;
    NSGlobalDomain.InitialKeyRepeat = 14;
    NSGlobalDomain.KeyRepeat = 1;
    # Dark mode everywhere, matching the Catppuccin Frappe theme used
    # across terminal/editor/CLI tooling (home/common/*).
    NSGlobalDomain.AppleInterfaceStyle = "Dark";
    NSGlobalDomain.AppleInterfaceStyleSwitchesAutomatically = false;
    # Disable autocorrect/text-substitution/prediction globally — interferes
    # with code/terminal/config text.
    NSGlobalDomain.NSAutomaticCapitalizationEnabled = false;
    NSGlobalDomain.NSAutomaticDashSubstitutionEnabled = false;
    NSGlobalDomain.NSAutomaticPeriodSubstitutionEnabled = false;
    NSGlobalDomain.NSAutomaticQuoteSubstitutionEnabled = false;
    NSGlobalDomain.NSAutomaticSpellingCorrectionEnabled = false;
    NSGlobalDomain.NSAutomaticInlinePredictionEnabled = false;
    NSGlobalDomain.AppleShowAllFiles = false;
    NSGlobalDomain.AppleEnableMouseSwipeNavigateWithScrolls = true;
    NSGlobalDomain.AppleEnableSwipeNavigateWithScrolls = true;
    NSGlobalDomain.AppleKeyboardUIMode = 0;
    # Otherwise held keys show the accent-picker popup instead of repeating,
    # which fights the fast KeyRepeat/InitialKeyRepeat set above.
    NSGlobalDomain.ApplePressAndHoldEnabled = false;
    NSGlobalDomain.AppleScrollerPagingBehavior = false;
    NSGlobalDomain.AppleSpacesSwitchOnActivate = true;
    # Consistent with universalaccess.reduceMotion in universalaccess.nix
    # (personal Macs only).
    NSGlobalDomain.NSAutomaticWindowAnimationsEnabled = false;
    NSGlobalDomain.NSUseAnimatedFocusRing = false;
    NSGlobalDomain.NSScrollAnimationEnabled = false;
    NSGlobalDomain.NSDocumentSaveNewDocumentsToCloud = false;
    NSGlobalDomain.AppleWindowTabbingMode = "fullscreen";
    NSGlobalDomain.NSNavPanelExpandedStateForSaveMode = false;
    NSGlobalDomain.NSNavPanelExpandedStateForSaveMode2 = false;
    NSGlobalDomain.NSTableViewDefaultSizeMode = 3;
    NSGlobalDomain.NSTextShowsControlCharacters = false;
    NSGlobalDomain.NSWindowResizeTime = 0.20;
    NSGlobalDomain.NSWindowShouldDragOnGesture = false;
    NSGlobalDomain."com.apple.sound.beep.feedback" = 1;
    NSGlobalDomain."com.apple.trackpad.enableSecondaryClick" = true;
    NSGlobalDomain."com.apple.swipescrolldirection" = false;
    # Extends the 24-hour menu-bar clock choice below system-wide.
    NSGlobalDomain.AppleICUForce24HourTime = true;
    NSGlobalDomain._HIHideMenuBar = false;

    screencapture.location = "/Users/anders/Pictures/Screenshots";
    screencapture.type = "png";
    screencapture.disable-shadow = false;
    screencapture.include-date = true;
    screencapture.save-selections = true;
    screencapture.show-thumbnail = true;
    screencapture.target = "file";

    menuExtraClock.Show24Hour = true;
    menuExtraClock.ShowDate = 1;
    menuExtraClock.IsAnalog = false;

    screensaver.askForPassword = true;
    screensaver.askForPasswordDelay = 0;

    loginwindow.GuestEnabled = false;
    loginwindow.SHOWFULLNAME = false;
    loginwindow.ShutDownDisabled = false;
    loginwindow.SleepDisabled = false;
    loginwindow.RestartDisabled = false;
    loginwindow.ShutDownDisabledWhileLoggedIn = false;
    loginwindow.PowerOffDisabledWhileLoggedIn = false;
    loginwindow.RestartDisabledWhileLoggedIn = false;
    loginwindow.DisableConsoleAccess = false;
    LaunchServices.LSQuarantine = true;

    finder.AppleShowAllExtensions = true;
    finder.FXPreferredViewStyle = "clmv";
    finder.ShowPathbar = true;
    finder.ShowStatusBar = true;
    finder._FXShowPosixPathInTitle = true;
    finder._FXSortFoldersFirst = true;
    finder.FXEnableExtensionChangeWarning = false;
    finder.AppleShowAllFiles = false;
    finder.FXRemoveOldTrashItems = false;
    finder.CreateDesktop = true;
    finder.QuitMenuItem = false;
    finder.ShowExternalHardDrivesOnDesktop = true;
    finder.ShowHardDrivesOnDesktop = false;
    finder.ShowMountedServersOnDesktop = false;
    finder.ShowRemovableMediaOnDesktop = true;
    finder._FXEnableColumnAutoSizing = false;
    finder._FXSortFoldersFirstOnDesktop = false;
    finder.NewWindowTarget = "Recents";

    WindowManager.GloballyEnabled = false; # Stage Manager off
    WindowManager.EnableStandardClickToShowDesktop = true;
    WindowManager.AutoHide = false;
    WindowManager.EnableTilingByEdgeDrag = true;
    WindowManager.EnableTopTilingByEdgeDrag = true;
    WindowManager.EnableTilingOptionAccelerator = true;
    WindowManager.EnableTiledWindowMargins = true;

    hitoolbox.AppleFnUsageType = "Do Nothing";

    # Requires logout to take effect.
    spaces.spans-displays = true;

    iCal."first day of week" = "Monday";
    iCal.CalendarSidebarShown = true;
    iCal."TimeZone support enabled" = false;

    smb.NetBIOSName = config.networking.hostName;
    smb.ServerDescription = config.networking.hostName;

    controlcenter.NowPlaying = false;

    # Real current value on this machine (0-3 scale).
    ".GlobalPreferences"."com.apple.mouse.scaling" = 2.0;

    ActivityMonitor.ShowCategory = 101; # All Processes, Hierarchically
    ActivityMonitor.SortColumn = "CPUUsage";
    ActivityMonitor.SortDirection = 0; # descending
    ActivityMonitor.OpenMainWindow = true;
  };

  # Caps Lock -> Control (terminal/emacs-style bindings).
  system.keyboard.enableKeyMapping = true;
  system.keyboard.remapCapsLockToControl = true;
  system.keyboard.remapCapsLockToEscape = false;
  system.keyboard.nonUS.remapTilde = false;
  system.keyboard.swapLeftCommandAndLeftAlt = false;
  system.keyboard.swapRightCommandAndRightOption = false;
  system.keyboard.swapCapsLockAndEscape = false;
  system.keyboard.swapLeftCtrlAndFn = false;

  # Make zsh the default user shell
  programs.zsh.enable = true;

  # User account (matches ahokinson/dotfiles /Users/anders). Default shell is
  # nixpkgs-managed zsh (overrides the stock macOS zsh so it tracks nixpkgs).
  users.users."anders" = {
    name = "anders";
    home = "/Users/anders";
    shell = pkgs.zsh;
  };

  # State version for nix-darwin
  system.stateVersion = 4;
}

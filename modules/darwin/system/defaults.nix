{
  config,
  selfPath,
  username,
  ...
}:
let
  dockApps = import (selfPath "home/common/dock-apps.nix");
in
{
  # macOS user defaults, set exhaustively so all 3 Macs stay identical
  # (except universalaccess.*, which has its own module).
  system.defaults = {
    dock.autohide = true;
    dock.magnification = false;
    # Finder is always pinned by macOS regardless of what's declared here.
    # Including it would risk a duplicate icon, so it's omitted.
    dock.persistent-apps = with dockApps; [
      "/Users/${username}/Applications/Home Manager Apps/${zen.darwinApp}"
      "/Users/${username}/Applications/Home Manager Apps/${ghostty.darwinApp}"
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
    dock.tilesize = 32;
    dock.largesize = 16;

    # Verified against this machine's actual settings, not nix-darwin's docs
    # (which claim different defaults for Clicking/TrackpadRightClick/
    # swipescrolldirection).
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
    # Dark mode, matching the Catppuccin Frappe theme used across
    # terminal/editor/CLI tooling.
    NSGlobalDomain.AppleInterfaceStyle = "Dark";
    NSGlobalDomain.AppleInterfaceStyleSwitchesAutomatically = false;
    # Autocorrect/text-substitution/prediction off: interferes with
    # code/terminal/config text.
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
    # Otherwise held keys show the accent-picker popup instead of repeating.
    NSGlobalDomain.ApplePressAndHoldEnabled = false;
    NSGlobalDomain.AppleScrollerPagingBehavior = false;
    NSGlobalDomain.AppleSpacesSwitchOnActivate = true;
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
    NSGlobalDomain.AppleICUForce24HourTime = true;
    NSGlobalDomain._HIHideMenuBar = false;

    screencapture.location = "/Users/${username}/Pictures/Screenshots";
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

    spaces.spans-displays = true; # Requires logout to take effect.

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

    SoftwareUpdate.AutomaticallyInstallMacOSUpdates = true;
  };
}

# Personal Macs only. macbookpro16-m5 is MDM-managed and a configuration
# profile blocks writes to com.apple.universalaccess, aborting activation
# with "Could not write domain com.apple.universalaccess; exiting". The same
# error also shows up on non-MDM Macs if the terminal app running
# darwin-rebuild lacks Full Disk Access (System Settings > Privacy &
# Security > Full Disk Access) — plain Accessibility access isn't enough.
{
  system.defaults.universalaccess = {
    reduceMotion = true;
    reduceTransparency = false; # keeps the menu bar/Dock/sidebars translucent
    mouseDriverCursorSize = 1.0;
    closeViewScrollWheelToggle = false;
    closeViewZoomFollowsFocus = false;
  };
}

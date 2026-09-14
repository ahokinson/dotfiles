# Personal Macs only. macbookpro16-m5 is MDM-managed and a configuration
# profile blocks writes to com.apple.universalaccess, aborting activation
# with "Could not write domain com.apple.universalaccess; exiting".
{
  system.defaults.universalaccess = {
    reduceMotion = true;
    reduceTransparency = false; # keeps the menu bar/Dock/sidebars translucent
    mouseDriverCursorSize = 1.0;
    closeViewScrollWheelToggle = false;
    closeViewZoomFollowsFocus = false;
  };
}

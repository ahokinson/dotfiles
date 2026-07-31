# macOS Accessibility (universalaccess) defaults - imported only by the
# personal Macs. On macbookpro16-m5 (work-managed laptop under MDM), writing
# to the com.apple.universalaccess domain is blocked by a configuration
# profile and aborts nix-darwin activation ("Could not write domain
# com.apple.universalaccess; exiting"), so that host omits this import.
{
  system.defaults.universalaccess = {
    reduceMotion = true;
    reduceTransparency = true;
    mouseDriverCursorSize = 1.0;
    closeViewScrollWheelToggle = false;
    closeViewZoomFollowsFocus = false;
  };
}

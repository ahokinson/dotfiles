{
  isDarwin,
  sharedFonts,
  ...
}:
# macOS installs fonts system-wide (modules/darwin/system) and ignores
# fontconfig, so home-level font packages are Linux-only.
if isDarwin then [ ] else sharedFonts.packages

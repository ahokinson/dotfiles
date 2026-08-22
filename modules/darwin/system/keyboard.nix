{ ... }: {
  # Caps Lock -> Control (terminal/emacs-style bindings).
  system.keyboard.enableKeyMapping = true;
  system.keyboard.remapCapsLockToControl = true;
  system.keyboard.remapCapsLockToEscape = false;
  system.keyboard.nonUS.remapTilde = false;
  system.keyboard.swapLeftCommandAndLeftAlt = false;
  system.keyboard.swapRightCommandAndRightOption = false;
  system.keyboard.swapCapsLockAndEscape = false;
  system.keyboard.swapLeftCtrlAndFn = false;
}

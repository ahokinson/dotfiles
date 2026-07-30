# Add to system/home-manager only on macOS hosts.
{ ... }: {
  imports = [
    ./zsh
  ];
}
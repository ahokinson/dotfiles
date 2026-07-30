# Imports all common tool modules. Apply via home-manager sharedHomeModule
# from each platform entrypoint (nixos host, darwin host, asahi standalone).
{ ... }: {
  imports = [
    ./bloom
    ./btop
    ./claude
    ./cupcake
    ./fastfetch
    ./git
    ./ghostty
    ./go-task
    ./hermes
    ./k9s
    ./lazydocker
    ./lazygit
    ./nvim
    ./opencode
    ./tmux
    ./yt-dlp
    ./zsh
    ./packages.nix
  ];
}
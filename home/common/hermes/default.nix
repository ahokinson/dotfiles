{ pkgs, ... }: {
  home.packages = [ pkgs.hermes ];

  # Hermes reads its config from ~/.hermes/
  home.file.".hermes" = {
    source = ./config-files;
    recursive = true;
  };
}

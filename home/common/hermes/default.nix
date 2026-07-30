{ pkgs, ... }: {
  home.packages = [ pkgs.hermes ];

  home.file.".hermes" = {
    source = ./config-files;
    recursive = true;
  };

  home.file.".hermes/SOUL.md".source = ../_shared/SOUL.md;
}

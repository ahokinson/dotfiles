{ selfPath, pkgs, ... }: {
  home.packages = [ pkgs.hermes ];

  home.file.".hermes" = {
    source = selfPath "home/common/hermes/config-files";
    recursive = true;
  };

  home.file.".hermes/SOUL.md".source = selfPath "home/common/_shared/SOUL.md";
}

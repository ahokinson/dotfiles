{ pkgs, ... }: {
  home.packages = [ pkgs.cupcake ];

  # cupcake policy store + tests live under ~/.cupcake/.
  home.file.".cupcake" = {
    source = ./_files;
    recursive = true;
  };
}

{
  config,
  inputs,
  pkgs,
  lib,
  ...
}:
let
  # Keep in sync with the `parsers` list in ahokinson/nvim's
  # lua/custom/plugins/treesitter.lua. A language listed there but not here
  # falls back to nvim-treesitter's runtime install on first use.
  treesitterParserNames = [
    "bash"
    "c"
    "diff"
    "go"
    "html"
    "javascript"
    "jsdoc"
    "json"
    "lua"
    "luadoc"
    "luap"
    "markdown"
    "markdown_inline"
    "python"
    "query"
    "regex"
    "rust"
    "toml"
    "tsx"
    "typescript"
    "vim"
    "vimdoc"
    "yaml"
    "zig"
  ];
  # Each grammarPlugins.<lang> holds just parser/<lang>.so, linked in by name
  # so the result stays auditable file-by-file.
  nvimTreesitterParsers = pkgs.runCommand "nvim-treesitter-parsers" { } (
    "mkdir -p $out/parser\n"
    + lib.concatMapStrings (n: ''
      ln -s ${pkgs.vimPlugins.nvim-treesitter.grammarPlugins.${n}}/parser/${n}.so $out/parser/${n}.so
    '') treesitterParserNames
  );

  # lazy.nvim rewrites lazy-lock.json whenever it installs, updates or syncs,
  # and `require("lazy").setup` takes no opts table upstream, so the path is
  # its default of $XDG_CONFIG_HOME/nvim. Withholding the file from the linked
  # tree leaves somewhere writable for the copy planted below to sit.
  nvimConfig = pkgs.runCommand "nvim-config" { } ''
    cp -r --no-preserve=mode ${inputs.nvim} $out
    rm $out/lazy-lock.json
  '';

  nvimConfigDir = "${config.xdg.configHome}/nvim";
  nvimLockfile = "${nvimConfigDir}/lazy-lock.json";
in
{
  home.packages = with pkgs; [
    neovim
    tree-sitter

    # telescope-fzf-native gates its own spec on `executable("make")`, so
    # without make lazy skips it outright rather than failing loudly.
    gnumake

    # mason cannot serve a NixOS host: it fetches prebuilt, dynamically
    # linked binaries, and /lib/ld-linux-aarch64.so.1 here is nixpkgs'
    # stub-ld, so nothing it downloads can exec. On aarch64-linux much of its
    # registry has no build at all, which is why the Asahi hosts notice and
    # the Macs do not. Each name below covers an entry in the
    # `ensure_installed` lists in ahokinson/nvim's
    # lua/custom/plugins/lspconfig.lua; lspconfig and nvim-lint resolve every
    # command from PATH, so nix satisfying them is enough. Left out because
    # packages.nix already carries them: golangci-lint, hadolint, ruff,
    # rust-analyzer, stylua. Left out because it belongs to a project's
    # node_modules rather than the profile: eslint.
    docker-compose-language-service
    dockerfile-language-server
    gopls
    helm-ls
    lua-language-server
    # nvim-lint invokes `markdownlint`, the binary only the -cli package
    # ships; markdownlint-cli2 installs a differently named one.
    markdownlint-cli
    marksman
    prettier
    terraform-ls
    tflint
    ty
    typescript-language-server
    yaml-language-server
    yamllint
    zls
  ];

  # github:ahokinson/nvim, taken as a plain source tree, not a flake.
  # recursive = true so the directory itself is real and writable; every file
  # under it is still a read-only store symlink.
  xdg.configFile."nvim" = {
    source = nvimConfig;
    recursive = true;
  };

  # Until this module went recursive the directory was one symlink into the
  # store, and cleanOldGen will not retract it: the path still resolves in the
  # new generation, so it is skipped as live rather than deleted. linkNewGen
  # would then follow it and write through into the read-only store. Droppable
  # once every host has rebuilt past the switch.
  home.activation.nvimUnlinkStaleConfigDir =
    lib.hm.dag.entryBetween [ "linkGeneration" ] [ "writeBoundary" ]
      ''
        if [[ -L ${lib.escapeShellArg nvimConfigDir} ]]; then
          run rm $VERBOSE_ARG ${lib.escapeShellArg nvimConfigDir}
        fi
      '';

  # The flake input stays the source of truth for plugin revisions, so this
  # overwrites rather than seeds: a rebuild resets the lock and `:Lazy
  # restore` puts the tree back on the pinned commits. After linkGeneration
  # specifically, not just the write boundary, because the directory it lands
  # in is created there.
  home.activation.nvimLazyLock = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
    run rm -f $VERBOSE_ARG ${lib.escapeShellArg nvimLockfile}
    run install -m 0644 ${inputs.nvim}/lazy-lock.json ${lib.escapeShellArg nvimLockfile}
  '';

  # Pre-populates nvim-treesitter's parser dir, so it never has to compile
  # or fetch on first launch. recursive = true keeps the directory writable
  # for anything not pinned here.
  xdg.dataFile."nvim/site/parser" = {
    source = "${nvimTreesitterParsers}/parser";
    recursive = true;
  };
}

{
  pkgs,
  lib,
  ...
}: {
  home.packages = [ pkgs.k9s ];

  xdg.configFile."k9s/config.yaml".text = lib.generators.toYAML { } {
    k9s = {
      liveViewAutoRefresh = false;
      screenDumpDir = "/tmp/k9s-screens";
      refreshRate = 2;
      maxConnRetry = 5;
      readOnly = false;
      noExitOnCtrlC = false;
      skipLatestRevCheck = false;
      disablePodCounting = false;
      shellPod = {
        image = "busybox:1.35.0";
        namespace = "default";
        limits = {
          cpu = "100m";
          memory = "100Mi";
        };
      };
      imageScans = {
        enable = false;
        exclusions = {
          namespaces = [ ];
          labels = { };
        };
      };
      logger = {
        tail = 100;
        buffer = 5000;
        sinceSeconds = -1;
        textWrap = false;
        showTime = false;
      };
      thresholds = {
        cpu = {
          critical = 90;
          warn = 70;
        };
        memory = {
          critical = 90;
          warn = 70;
        };
      };
      ui = {
        enableMouse = false;
        headless = false;
        logoless = false;
        crumbsless = false;
        reactive = false;
        noIcons = false;
        skin = "catppuccin-mocha";
      };
    };
  };

  xdg.configFile."k9s/plugins.yaml".text = lib.generators.toYAML { } {
    plugins = {
      # Debug pod with ephemeral container
      debug = {
        shortCut = "Shift-D";
        description = "Add debug container";
        scopes = [ "pods" ];
        command = "kubectl";
        background = false;
        args = [
          "debug"
          "-it"
          "-n"
          "$NAMESPACE"
          "$NAME"
          "--image=nicolaka/netshoot:v0.11"
          "--target=$NAME"
        ];
      };

      # Open shell in a pod with sh (for minimal images)
      shell-sh = {
        shortCut = "Shift-S";
        description = "Shell (sh)";
        scopes = [ "containers" ];
        command = "sh";
        background = false;
        args = [
          "-c"
          "kubectl exec -it -n $NAMESPACE $POD -c $NAME -- sh"
        ];
      };

      # Logs with stern (if installed)
      stern = {
        shortCut = "Ctrl-L";
        description = "Logs with stern";
        scopes = [ "pods" ];
        command = "bash";
        background = false;
        args = [
          "-c"
          "stern --tail 50 -n $NAMESPACE $NAME"
        ];
      };

      # Port-forward shortcut
      port-forward = {
        shortCut = "Shift-F";
        description = "Port Forward";
        scopes = [ "pods" ];
        command = "bash";
        background = false;
        args = [
          "-c"
          "kubectl port-forward -n $NAMESPACE $NAME"
        ];
      };

      # Get YAML
      get-yaml = {
        shortCut = "y";
        description = "Get YAML";
        scopes = [ "all" ];
        command = "bash";
        background = false;
        args = [
          "-c"
          "kubectl get -n $NAMESPACE $RESOURCE_NAME $NAME -o yaml | less"
        ];
      };
    };
  };

  xdg.configFile."k9s/skins/catppuccin-mocha.yaml".text = lib.generators.toYAML { } {
    k9s = {
      body = {
        fgColor = "#cdd6f4";
        bgColor = "default";
        logoColor = "#cba6f7";
      };
      prompt = {
        fgColor = "#cdd6f4";
        bgColor = "default";
        suggestColor = "#89b4fa";
      };
      help = {
        fgColor = "#cdd6f4";
        bgColor = "default";
        sectionColor = "#a6e3a1";
        keyColor = "#89b4fa";
        numKeyColor = "#eba0ac";
      };
      frame = {
        title = {
          fgColor = "#94e2d5";
          bgColor = "default";
          highlightColor = "#f5c2e7";
          counterColor = "#f9e2af";
          filterColor = "#a6e3a1";
        };
        border = {
          fgColor = "#cba6f7";
          focusColor = "#b4befe";
        };
        menu = {
          fgColor = "#cdd6f4";
          keyColor = "#89b4fa";
          numKeyColor = "#eba0ac";
        };
        crumbs = {
          fgColor = "#1e1e2e";
          bgColor = "#eba0ac";
          activeColor = "#f2cdcd";
        };
        status = {
          newColor = "#89b4fa";
          modifyColor = "#b4befe";
          addColor = "#a6e3a1";
          pendingColor = "#fab387";
          errorColor = "#f38ba8";
          highlightColor = "#89dceb";
          killColor = "#cba6f7";
          completedColor = "#6c7086";
        };
      };
      info = {
        fgColor = "#fab387";
        sectionColor = "#cdd6f4";
      };
      views = {
        table = {
          fgColor = "#cdd6f4";
          bgColor = "default";
          cursorFgColor = "#313244";
          cursorBgColor = "#45475a";
          markColor = "#f5e0dc";
          header = {
            fgColor = "#f9e2af";
            bgColor = "default";
            sorterColor = "#89dceb";
          };
        };
        xray = {
          fgColor = "#cdd6f4";
          bgColor = "default";
          cursorColor = "#45475a";
          cursorTextColor = "#1e1e2e";
          graphicColor = "#f5c2e7";
        };
        charts = {
          bgColor = "default";
          chartBgColor = "default";
          dialBgColor = "default";
          defaultDialColors = [
            "#a6e3a1"
            "#f38ba8"
          ];
          defaultChartColors = [
            "#a6e3a1"
            "#f38ba8"
          ];
          resourceColors = {
            cpu = [
              "#cba6f7"
              "#89b4fa"
            ];
            mem = [
              "#f9e2af"
              "#fab387"
            ];
          };
        };
        yaml = {
          keyColor = "#89b4fa";
          valueColor = "#cdd6f4";
          colonColor = "#a6adc8";
        };
        logs = {
          fgColor = "#cdd6f4";
          bgColor = "default";
          indicator = {
            fgColor = "#b4befe";
            bgColor = "default";
            toggleOnColor = "#a6e3a1";
            toggleOffColor = "#a6adc8";
          };
        };
      };
      dialog = {
        fgColor = "#f9e2af";
        bgColor = "#9399b2";
        buttonFgColor = "#1e1e2e";
        buttonBgColor = "#7f849c";
        buttonFocusFgColor = "#1e1e2e";
        buttonFocusBgColor = "#f5c2e7";
        labelFgColor = "#f5e0dc";
        fieldFgColor = "#cdd6f4";
      };
    };
  };
}

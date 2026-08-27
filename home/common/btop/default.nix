{ selfPath, ... }: {
  xdg.configFile."btop/btop.conf".source = selfPath "home/common/btop/btop.conf";
  xdg.configFile."btop/themes/catppuccin_frappe.theme".source =
    selfPath "home/common/btop/themes/catppuccin_frappe.theme";
}

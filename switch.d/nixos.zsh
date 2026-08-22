# NixOS hardware signal -> flake output. Keys are matched as a substring
# against vendor/product/family concatenated — order tighter keys first
# (e.g. "Framework Laptop 13" matches "Framework / Laptop 13 (AMD Ryzen AI
# 300 Series)").
typeset -A NIXOS_HW_MAP=(
  "Framework Laptop 13"  "framework13-amd-ryzen"
)

detect_host_nixos() {
  local vendor product family hay
  vendor=$(cat /sys/class/dmi/id/sys_vendor 2>/dev/null || true)
  product=$(cat /sys/class/dmi/id/product_name 2>/dev/null || true)
  family=$(cat /sys/class/dmi/id/product_family 2>/dev/null || true)
  hay="$vendor $product $family"

  for needle in ${(k)NIXOS_HW_MAP}; do
    if [[ "$hay" == *"$needle"* ]]; then
      print "${NIXOS_HW_MAP[$needle]} $vendor $product"
      return
    fi
  done
  print "" "$vendor / $product(unknown)"
  return 1
}

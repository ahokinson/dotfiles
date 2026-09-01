# cosmic-manager encodes Rust `Option` and enum types over RON as tagged
# attrsets. These two shapes recur across the cosmic/* modules.
{
  ronOptional = value: {
    __type = "optional";
    inherit value;
  };
  ronEnum = variant: {
    __type = "enum";
    inherit variant;
  };
}

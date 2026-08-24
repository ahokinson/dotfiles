# cosmic-manager encodes Rust's `Option`/enum types over RON as tagged
# attrsets. These two shapes recur across the cosmic/* modules, so they're
# named here instead of hand-inlined at every call site.
{
  ronOptional = value: { __type = "optional"; inherit value; };
  ronEnum = variant: { __type = "enum"; inherit variant; };
}

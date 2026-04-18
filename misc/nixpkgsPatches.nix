[
  # Reactivex fix
  (builtins.fetchurl {
    url = "https://github.com/NixOS/nixpkgs/pull/508007.patch";
    sha256 = "sha256-mKM9upYuh6WlH52+WFLK+2IjmgPqT4nyI3IQQk9U5uY=";
  })
]
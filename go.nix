{
  config,
  pkgs,
  name,
  lib,
  ...
}: let
  inherit (lib) mkEnableOption mkOption mkIf types;
  inherit (types) nullOr str;
in {
  options.go = {
    enable = mkEnableOption "golang package and toolchain";
    vendorHash = mkOption {
      type = nullOr str;
      default = null;
    };
  };
  config = mkIf config.go.enable {
    shell.languages.go.enable = true;
    shell.pre-commit.hooks = {
      gofmt.enable = true;
      govet.enable = true;
      gotest.enable = true;
    };
    package = pkgs.buildGoModule {
      name = name;
      src = config.root;
      vendorHash = config.go.vendorHash;
    };
  };
}

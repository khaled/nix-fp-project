{
  inputs = {
    fp.url = "github:hercules-ci/flake-parts";
    devenv.url = "github:cachix/devenv";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };
  outputs = inputs @ {fp, ...}: let
    flake-module = import ./flake-module.nix;
  in
    fp.lib.mkFlake {inherit inputs;} {
      systems = ["x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin"];
      imports = [flake-module];
      flake.flakeModules.default = flake-module;
      
      # define a project using our own flake module
      projects.sample = {pkgs, ...}: {
        go.enable = true;
        shell.packages = [pkgs.delve];
      };
    };
}

{
  inputs,
  lib,
  config,
  ...
}: let
  inherit
    (lib)
    mkOption
    mkMerge
    mkForce
    mapAttrsToList
    evalModules
    types
    ;
  inherit (types) str path package deferredModule lazyAttrsOf;
  projectMod = {
    config,
    pkgs,
    name,
    inputs,
    ...
  }: {
    imports = [./go.nix];
    options = {
      attrName = mkOption {
        type = str;
        default = name;
      };
      root = mkOption {
        type = path;
        default = inputs.self;
      };
      package = mkOption {
        type = package;
      };
      shell = mkOption {
        type = deferredModule;
        default = {};
      };
      perSystem = mkOption {
        type = deferredModule;
      };
    };
    config.shell.containers = mkForce {};
    config.perSystem = {
      packages.${config.attrName} = config.package;
      devenv.shells.${config.attrName} = config.shell;
    };
  };
  evalProject = name: mod: ({
      # have to explicitly specify all the args we want
      # passed into project modules here
      self',
      inputs',
      pkgs,
      system,
      ...
    } @ inp:
      (evalModules {
        modules = [
          {_module.args = inp // {inherit name inputs;};}
          projectMod
          mod
        ];
      })
      .config
      .perSystem);
in {
  imports = [inputs.devenv.flakeModule];
  options = {
    projects = mkOption {
      type = lazyAttrsOf deferredModule;
    };
  };
  config.perSystem = mkMerge (mapAttrsToList
    evalProject
    (config.projects));
}

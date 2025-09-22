{
  description = "A monorepo for my personal Nix flakes";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    let
      lib = nixpkgs.lib;

      # 修正后的 importDir 函数
      importDir = path:
        let
          files = builtins.attrNames (builtins.readDir path);
          nixFiles = builtins.filter (file: lib.hasSuffix ".nix" file) files;
          attrs = lib.map (file: {
            name = lib.removeSuffix ".nix" file;
            value = import (path + "/${file}");
          }) nixFiles;
        in lib.listToAttrs attrs;

    in
    flake-utils.lib.eachDefaultSystem (system:
      let
        ourOverlays = importDir ./overlays;

        pkgs = import nixpkgs {
          inherit system;
          overlays = lib.attrValues ourOverlays;
        };

        ourPkgsRaw = importDir ./pkgs;
        ourPkgs = lib.mapAttrs (name: pkgFunc: pkgFunc { inherit pkgs; }) ourPkgsRaw;

        ourShellsRaw = importDir ./shells;
        ourShells = lib.mapAttrs (name: shellFunc: shellFunc { inherit pkgs; }) ourShellsRaw;

      in
      {
        overlays = ourOverlays;
        packages = ourPkgs;
        devShells = ourShells;
      });
}

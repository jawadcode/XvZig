{
  description = "An Implementation of the Xv6 Kernel in Zig.";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    systems.url = "github:nix-systems/default";
  };

  outputs = {
    # self,
    systems,
    nixpkgs,
    ...
  }: let
    lib = nixpkgs.lib;
    eachSystem = lib.genAttrs (import systems);
  in {
    devShells = eachSystem (system: let
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      default = pkgs.mkShell.override {stdenv = pkgs.clang19Stdenv;} {
        packages = with pkgs; [
          zig
          zls
          nasm
          qemu
          asm-lsp
        ];
      };
    });
  };
}

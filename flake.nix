{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nixpkgs-ancient-ruby = {
      url = "github:nixos/nixpkgs/21808d22b1cda1898b71cf1a1beb524a97add2c4";
      flake = false;
    };
    nixpkgs-ancient-node = {
      url = "github:nixos/nixpkgs/22f65339f3773f5b691f55b8b3a139e5582ae85b";
      flake = false;
    };
    nixpkgs-mysql57 = {
      url = "github:nixos/nixpkgs/df2176f7f3f748974f24916df29bb70763d89734";
      flake = false;
    };
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, nixpkgs-mysql57, ... } @ inputs:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        pkgs-ancient-node = import inputs.nixpkgs-ancient-node { inherit system; };
        pkgs-ancient-ruby = import inputs.nixpkgs-ancient-ruby { inherit system; };
        pkgs-mysql57 = import inputs.nixpkgs-mysql57 { inherit system; };
      in
      {
        formatter = pkgs.nixpkgs-fmt;
        devShells.default = pkgs.mkShell {
          packages = (with pkgs; [
            act
            pkgs-ancient-node.nodejs-10_x # Node.js v10.15.3
          ]) ++ (with pkgs-ancient-ruby; [
            ruby_3_3 # Ruby v3.3.7
            glibc # Includes 'libcrypt'
            libffi # Needed for 'ffi' Gem
            pkgs-mysql57.mysql57
            zlib
            openssl
            sqlite
            xz # Needed for nokogiri Gem
            libyaml
          ]);
        };
      }
    );
}
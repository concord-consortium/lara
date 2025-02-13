{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nixpkgs-ancient-ruby = {
      url = "github:nixos/nixpkgs/f597e7e9fcf37d8ed14a12835ede0a7d362314bd";
      flake = false;
    };
    nixpkgs-ancient-node = {
      url = "github:nixos/nixpkgs/22f65339f3773f5b691f55b8b3a139e5582ae85b";
      flake = false;
    };
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, ... } @ inputs:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        pkgs-ancient-node = import inputs.nixpkgs-ancient-node {
          inherit system;
        };
        pkgs-ancient-ruby = import inputs.nixpkgs-ancient-ruby {
          inherit system;
        };
      in
      {
        formatter = pkgs.nixpkgs-fmt;
        devShells.default = pkgs.mkShell {
          packages = (with pkgs; [
            act
            pkgs-ancient-node.nodejs-10_x # Node.js v10.15.3
          ]) ++ (with pkgs-ancient-ruby; [
            ruby_3_1 # Ruby v3.1.0
            glibc # Includes 'libcrypt'
            libffi # Needed for 'ffi' Gem
            mysql57
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
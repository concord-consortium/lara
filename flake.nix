{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nixpkgs-old-ruby = {
      url = "github:nixos/nixpkgs/0bcbb978795bab0f1a45accc211b8b0e349f1cdb";
      flake = false;
    };
    nixpkgs-old-node = {
      url = "github:nixos/nixpkgs/22f65339f3773f5b691f55b8b3a139e5582ae85b";
      flake = false;
    };
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, ... } @ inputs:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        pkgs-old-node = import inputs.nixpkgs-old-node {
          inherit system;
        };
        pkgs-old-ruby = import inputs.nixpkgs-old-ruby {
          inherit system;
        };
      in
      {
        formatter = pkgs.nixpkgs-fmt;
        devShells.default = pkgs.mkShell {
          packages = (with pkgs; [
            act
            pkgs-old-node.nodejs-10_x # Node.js v10.15.3
          ]) ++ (with pkgs-old-ruby; [
            ruby_2_3 # Ruby v2.3.7
            glibc # Includes 'libcrypt'
            libffi # Needed for 'ffi' Gem
            mysql57
            zlib
            openssl
            sqlite
            xz # Needed for nokogiri Gem
          ]);
        };
      }
    );
}

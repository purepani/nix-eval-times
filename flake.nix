{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nix.url = "github:nixos/nix";
    test_nixpkgs = {
      url = "github:nixos/nixpkgs/nixpkgs-unstable";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, nix, test_nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      lib = builtins // nixpkgs.lib;

      release-combined = import "${test_nixpkgs}/nixos/release-combined.nix" { };
      ec2 = release-combined.nixos.closures.ec2.${system};
      kde = release-combined.nixos.closures.kde.${system};
      lapp = release-combined.nixos.closures.lapp.${system};
      python = pkgs.python313;



    in
    {

      devShells.${system}.default = pkgs.mkShell {
        packages = [
          nix.packages.${system}.default
          python
          pkgs.uv
        ];
        env =
          {
            # Prevent uv from managing Python downloads
            UV_PYTHON_DOWNLOADS = "never";
            # Force uv to use nixpkgs Python interpreter
            UV_PYTHON = python.interpreter;
          }
          // lib.optionalAttrs pkgs.stdenv.isLinux {
            # Python libraries often load native shared objects using dlopen(3).
            # Setting LD_LIBRARY_PATH makes the dynamic library loader aware of libraries without using RPATH for lookup.
            LD_LIBRARY_PATH = lib.makeLibraryPath pkgs.pythonManylinuxPackages.manylinux1;
          };
        shellHook = ''
          unset PYTHONPATH
        '';
      };

      packages.${system} = {
        inherit ec2 kde lapp;
      };

    };
}

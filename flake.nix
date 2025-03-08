{
  description = "";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nixpkgs-stable.url = "nixpkgs/release-24.11";
    utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, nixpkgs-stable, utils }:
    utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
        name = "generate";
        buildInputs = with pkgs; [ jq yq-go just ];
        generate = (
          pkgs.writeScriptBin name (builtins.readFile ./generate.bash)
        ).overrideAttrs(old: {
          buildCommand = "${old.buildCommand}\n patchShebangs $out";
        });
      in rec {
        packages.generate = pkgs.symlinkJoin {
          name = name;
          paths = [ generate ] ++ buildInputs;
          buildInputs = [ pkgs.makeWrapper ];
          postBuild = "wrapProgram $out/bin/${name} --prefix PATH : $out/bin";
        };

        defaultPackage = packages.generate;

        devShells.default = pkgs.mkShell {
          packages = (with pkgs; [
            jq
            yq-go
            just
          ]);

          inputsFrom = [];
        };
      }
    );
}

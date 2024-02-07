{
  description = "Development shell for Flows project";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      formatter = pkgs.alejandra;

      devShell = pkgs.mkShell {
        packages = with pkgs; [
          ruby_3_3
          lefthook
        ];

        # install gems in local directory
        shellHook = ''
          export GEM_HOME="$PWD/.env/ruby"
          export GEMRC="$GEM_HOME/.gemrc"
          export RUBY_CONFDIR="$PWD/.env/ruby"
          export PATH="$PWD/.env/ruby/bin:$PATH"
        '';
      };
    });
}

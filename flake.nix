{
  description = "NixOS Integration Test Driver Demo for Nixcon";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-parts.inputs.nixpkgs-lib.follows = "nixpkgs";

    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    treefmt.url = "github:numtide/treefmt-nix";
  };

  outputs =
    inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
      ];
      imports = [
        inputs.treefmt.flakeModule
      ];
      perSystem =
        {
          pkgs,
          system,
          config,
          self',
          ...
        }:
        {

          packages = {
            ping = pkgs.testers.runNixOSTest ./ping;
            echo = pkgs.testers.runNixOSTest ./echo;
            browser = pkgs.testers.runNixOSTest ./browser;
          };

          checks = config.packages // {
            # let `nix flake check` fill up the nix store with these
            ping-interactive = config.packages.ping.driverInteractive;
            echo-interactive = config.packages.echo.driverInteractive;
            browser-interactive = config.packages.browser.driverInteractive;
          };

          devShells.default = pkgs.mkShell {
            packages = [ self'.formatter ];
          };

          treefmt = {
            programs.deadnix.enable = true;
            programs.statix.enable = true;
            programs.nixfmt.enable = true;
          };

          _module.args.pkgs = import inputs.nixpkgs {
            inherit system;
            overlays = [ (import ./overlay.nix) ];
            config = { };
          };
        };
    };
}

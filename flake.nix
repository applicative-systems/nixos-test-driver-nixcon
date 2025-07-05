{
  description = "NixOS Integration Test Driver Demo for Nixcon";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-parts.inputs.nixpkgs-lib.follows = "nixpkgs";

    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } {
    systems = [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" ];
    perSystem = { pkgs, system, config, ... }: {

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

      _module.args.pkgs = import inputs.nixpkgs {
        inherit system;
        overlays = [ (import ./overlay.nix) ];
        config = { };
      };
    };
  };
}

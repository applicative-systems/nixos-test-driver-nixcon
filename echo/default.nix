{
  name = "Echo Service Test";

  nodes = {
    server = { config, pkgs, ... }: {
      imports = [
        ./echo-nixos-module.nix
      ];

      services.echo.enable = true;

      networking.firewall.allowedTCPPorts = [
        config.services.echo.port
      ];
    };
    client = { ... }: { };
  };

  globalTimeout = 200;

  interactive.nodes.server = import ../debug-host-module.nix;

  testScript = { nodes, ... }: ''
    ECHO_PORT = ${builtins.toString nodes.server.services.echo.port}
    ECHO_TEXT = "Hello, world!"

    start_all()

    server.wait_for_unit("echo.service")
    server.wait_for_open_port(ECHO_PORT)

    client.systemctl("start network-online.target")
    client.wait_for_unit("network-online.target")
    output = client.succeed(f"echo '{ECHO_TEXT}' | nc -N server {ECHO_PORT}")
    assert ECHO_TEXT in output
  '';
}

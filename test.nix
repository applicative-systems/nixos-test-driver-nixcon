{ pkgs, lib, ... }:
let
  nixpkgs = pkgs.path;
in
{
  name = "nixcon24-demo-test";
  globalTimeout = 100;

  enableOCR = true;

  defaults = {
    networking.firewall.enable = false;
    virtualisation.resolution = { x = 800; y = 600; };
  };

  nodes = {
    server = {
      services.httpd.enable = true;
      networking.firewall.allowedTCPPorts = [ 80 ];

    };
    client = {
      imports = [ (nixpkgs + "/nixos/tests/common/x11.nix") ];

      programs.firefox.enable = true;

      environment.systemPackages = [
        pkgs.xdotool
      ];
    };
  };

  testScript = { nodes, ... }:
    let
      firefox = lib.getExe nodes.client.programs.firefox.package;
    in
    ''
      start_all()

      for m in [ client, server ]:
        m.wait_for_unit("network-online.target")

      server.succeed("ping -c 1 client")
      client.succeed("ping -c 1 server")

      client.wait_for_x()

      with subtest("open and close firefox"):
        client.succeed("xterm -e '${firefox} about:welcome' >&2 &")
        client.wait_for_window("Firefox")
        client.sleep(5)
        client.succeed("xdotool key ctrl+q")
        client.sleep(1)
        screen_content = client.get_screen_text()
        assert "Quit Firefox" in screen_content, "Firefox asks for confirmation"
        client.succeed("xdotool key space")
        client.sleep(1)

      with subtest("open website on server"):
        client.succeed("xterm -e '${firefox} http://server' >&2 &")
        client.wait_for_window("Firefox")
        client.sleep(5)

        client.screenshot("it-works")

        screen_content = client.get_screen_text()
        print(screen_content)
        assert "It works!" in screen_content, "It works! page is on screen"
    '';
}

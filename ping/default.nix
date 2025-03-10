{
  name = "An awesome test.";

  nodes = {
    machine1 = { pkgs, ... }: {
      # Empty config sets some defaults
    };
    machine2 = { pkgs, ... }: { };
  };

  globalTimeout = 30;

  interactive.nodes.machine1 = import ../debug-host-module.nix;

  testScript = ''
    machine1.systemctl("start network-online.target")
    machine2.systemctl("start network-online.target")

    machine1.wait_for_unit("network-online.target")
    machine2.wait_for_unit("network-online.target")

    machine1.succeed("ping -c 1 machine2")
    machine2.succeed("ping -c 1 machine1")
  '';
}

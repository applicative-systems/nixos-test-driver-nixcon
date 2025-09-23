{
  name = "An awesome test.";

  nodes = {
    machine1 = {
      # Empty config sets some defaults
    };
    machine2 = { };
  };

  globalTimeout = 300;

  interactive.nodes.machine1 = import ../debug-host-module.nix;

  testScript = ''
    start_all()

    # we *have* to start network-online.target because for some time it's not
    # implicitly needed by multi-user.target any longer (like in all other
    # distros) and if we don't start any service that depends on it (this test
    # doesn't), then we will not get this target to become ready.
    # other tests that don't just ping but use normal services that expect
    # networking won't need to do this.
    machine1.systemctl("start network-online.target")
    machine2.systemctl("start network-online.target")

    machine1.wait_for_unit("network-online.target")
    machine2.wait_for_unit("network-online.target")

    machine1.succeed("ping -c 1 machine2")
    machine2.succeed("ping -c 1 machine1")
  '';
}

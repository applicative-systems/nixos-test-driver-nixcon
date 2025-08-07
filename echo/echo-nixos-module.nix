{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.services.echo;
in
{
  options.services.echo = {
    enable = lib.mkEnableOption "TCP echo as a Service";
    port = lib.mkOption {
      type = lib.types.port;
      default = 8081;
      description = "Port to listen on";
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.echo = {
      description = "Friendly TCP Echo as a Service Daemon";
      wantedBy = [ "multi-user.target" ];
      serviceConfig.ExecStart = ''
        ${pkgs.python3}/bin/python3 ${./echo-server.py} ${builtins.toString cfg.port}
      '';
    };
  };
}

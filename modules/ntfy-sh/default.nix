{ lib, config, ... }:
with lib;
let
  cfg = config.pinpox.services.ntfy-sh;
  ntfy-port = "8090";
  ntfy-host = "push.pablo.tools";
in
{

  options.pinpox.services.ntfy-sh = {
    enable = mkEnableOption "ntfy-sh notification server";
  };

  config = mkIf cfg.enable {

    services.ntfy-sh = {
      enable = true;
      settings = {
        behind-proxy = true;
        listen-http = "127.0.0.1:${ntfy-port}";
        base-url = "https://${ntfy-host}";
        auth-file = "/var/lib/ntfy-sh/user.db";
        auth-default-access = "deny-all";
        upstream-base-url = "https://ntfy.sh";
        # https://github.com/binwiederhier/ntfy/issues/459
        web-root = "disable"; # Set to "app" to enable web UI
      };
    };

    users.users.ntfy-sh = {
      home = "/var/lib/ntfy-sh";
      createHome = true;
    };

    services.caddy.virtualHosts."${ntfy-host}".extraConfig = ''
      reverse_proxy 127.0.0.1:${ntfy-port}
    '';
  };
}

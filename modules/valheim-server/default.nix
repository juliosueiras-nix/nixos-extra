self:

{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.valheim-server;
in {
  options = {
    services.valheim-server = {
      enable = mkOption {
        type = types.bool;
        default = false;
      };

      package = mkOption {
        type = types.package;
        default = self.packages.x86_64-linux.valheim-server;
      };

      password = mkOption {
        type = types.str;
      };

      port = mkOption {
        type = types.int;
        default = 2456;
      };

      displayName = mkOption {
        type = types.str;
      };

      worldName = mkOption {
        type = types.str;
      };

      public = mkOption {
        type = types.bool;
        default = true;
      };
    };
  };

  config = mkIf cfg.enable {
    systemd.services.valheim-server = {
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];

      serviceConfig = {
        ExecStart = ''${cfg.package}/bin/valheim-server -name "${cfg.displayName}" -port ${toString cfg.port} -nographics -batchmode -world "${cfg.worldName}" -password "${cfg.password}" -public "${if cfg.public then "1" else "0"}"'';
      };
    };
  };
}

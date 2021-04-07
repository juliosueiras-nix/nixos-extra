self:

{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.appsmith;
in {
  options = {
    services.appsmith = {
      enable = mkOption {
        type = types.bool;
        default = false;
      };

      serverPackage = mkOption {
        type = types.package;
        default = self.packages.x86_64-linux.appsmith-server;
      };

      clientPackage = mkOption {
        type = types.package;
        default = self.packages.x86_64-linux.appsmith-editor;
      };
    };
  };

  config = mkIf cfg.enable {
    services.nginx = {
      enable = true;
      virtualHosts = {
        "localhost" = {
          locations = let
            commonServerConfig = {
              extraConfig = ''
                proxy_set_header X-Forwarded-Proto $scheme;
                proxy_set_header X-Forwarded-Host $host;
              '';
              proxyPass = "http://localhost:8080";
            };
          in {
            "/" = {
              root = "${cfg.clientPackage}";
              tryFiles = "$uri $uri/ /index.html";
            };

            "/api" = commonServerConfig;
            "/oauth2" = commonServerConfig;
            "/login" = commonServerConfig;
          };
        };
      };
    };

    services.mongodb.enable = true;
    services.redis.enable = true;

    systemd.services.appsmith-server = {
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];

      environment = {
        APPSMITH_REDIS_URL = "redis://localhost:6379";
        APPSMITH_MONGODB_URI = "mongodb://localhost/appsmith?retryWrites=true";
        APPSMITH_ENCRYPTION_PASSWORD = "TestPassword";
        APPSMITH_ENCRYPTION_SALT = "TestSalt";
        APPSMITH_PLUGINS_DIR = "${cfg.serverPackage}/share/java/plugins";
      };

      script = "${cfg.serverPackage}/bin/appsmith-server";
    };
  };
}

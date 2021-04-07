self:

{ config, lib, pkgs, ... }:

with lib;

let cfg = config.services.appsmith;
in {
  options = {
    services.appsmith = {
      enable = mkOption {
        type = types.bool;
        default = false;
      };

      serverPackage = mkOption {
        type = types.package;
        default = self.packages.${builtins.currentSystem}.appsmith-server;
      };

      clientPackage = mkOption {
        type = types.package;
        default = self.packages.${builtins.currentSystem}.appsmith-editor;
      };

      pluginsDir = mkOption {
        type = types.str;
        default = "${cfg.serverPackage}/share/java/plugins";
      };

      hostname = mkOption {
        type = types.str;
        default = "localhost";
      };

      forceSSL = mkOption {
        type = types.bool;
        default = false;
      };

      encryption = {
        salt = mkOption {
          type = types.str;
          description = ''
            Encryption Salt for Appsmith
          '';
        };

        password = mkOption {
          type = types.str;
          description = ''
            Encryption Password for Appsmith
          '';
        };
      };

      redis = {
        local = mkOption {
          type = types.bool;
          default = true;
          description = ''
            Enable local redis
          '';
        };

        url = mkOption {
          type = types.str;
          default = "redis://localhost:6379";
          description = ''
            Redis url
          '';
        };
      };

      mongodb = {
        local = mkOption {
          type = types.bool;
          default = true;
          description = ''
            Enable local mongodb
          '';
        };

        url = mkOption {
          type = types.str;
          default = "mongodb://localhost/appsmith?retryWrites=true";
          description = ''
            Mongodb url
          '';
        };
      };
    };
  };

  config = mkMerge [
    (mkIf (cfg.enable && cfg.redis.local) { services.redis.enable = true; })
    (mkIf (cfg.enable && cfg.mongodb.local) { services.mongodb.enable = true; })
    (mkIf cfg.enable {
      services.nginx = {
        enable = true;
        virtualHosts = {
          "${cfg.hostname}" = {
            inherit (cfg) forceSSL;
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

      systemd.services.appsmith-server = {
        wantedBy = [ "multi-user.target" ];
        after = [ "network.target" ];

        environment = {
          APPSMITH_REDIS_URL = "${cfg.redis.url}";
          APPSMITH_MONGODB_URI = "${cfg.mongodb.url}";
          APPSMITH_ENCRYPTION_PASSWORD = "${cfg.encryption.password}";
          APPSMITH_ENCRYPTION_SALT = "${cfg.encryption.salt}";
          APPSMITH_PLUGINS_DIR = "${cfg.pluginsDir}";
        };

        script = "${cfg.serverPackage}/bin/appsmith-server";
      };
    })
  ];
}

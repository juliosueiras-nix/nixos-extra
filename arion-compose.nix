let
  appsmithModule = (import ./. {}).defaultNix.nixosModules.appsmith;
in {
  services.webserver = { pkgs, ... }: {
    nixos.useSystemd = true;
    nixos.configuration = {
      imports = [ appsmithModule ];
      boot.tmpOnTmpfs = true;

      services.appsmith = {
        enable = true;
        encryption = {
          salt = "TestSalt";
          password = "TestPassword";
        };
      };
    };
    service.useHostStore = true;
    service.ports = [
      "8000:80" # host:container
    ];
  };
}

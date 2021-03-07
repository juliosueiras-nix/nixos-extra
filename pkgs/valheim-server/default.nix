{ steamcmd, zlib, autoPatchelfHook, makeWrapper, stdenv, ... }:

let
  valheim-server-src = stdenv.mkDerivation {
    name = "valheim-server-src";

    unpackPhase = "true";   

    buildInputs = [ 
      steamcmd
    ];

    buildPhase = ''
      export HOME=$PWD
      steamcmd +login anonymous +force_install_dir $PWD/server +app_update 896660 validate +exit
      cd server
      rm UnityPlayer_s.debug
      rm LinuxPlayer*
      rm -rf steamapps
      rm steam_appid.txt
      cd ../
    '';

    installPhase = ''
      mkdir -p $out
      cp -a server/* $out
    '';

    outputHashAlgo = "sha256";
    outputHashMode = "recursive";
    outputHash = "JwAUXGlRyzMo+qJ+vCBfafSHnLjx622zVXNMUzUh5m0=";
  };
in stdenv.mkDerivation {
  name = "valheim-server";

  buildInputs = [
    autoPatchelfHook
    zlib
    makeWrapper
  ];

  src = valheim-server-src;

  installPhase = ''
    mkdir -p $out/bin
    cp -a * $out
    makeWrapper $out/valheim_server.x86_64 $out/bin/valheim-server --set SteamAppId 892970 --set LD_LIBRARY_PATH "$out/linux64:$LD_LIBRARY_PATH"
  '';
}

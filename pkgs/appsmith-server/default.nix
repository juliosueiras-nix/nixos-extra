{stdenv, fetchFromGitHub, maven, jdk11_headless, makeWrapper, ... }:

let
  src = fetchFromGitHub {
    owner = "appsmithorg";
    repo = "appsmith";
    rev = "v1.4.6";
    sha256 = "tnhzpX4KluOH41NXDDsbsbhTQYz+ghvU/OAgR8sEpQE=";
  };

  deps = stdenv.mkDerivation {
    name = "appsmith-server-deps";

    buildInputs = [ (maven.override {
      jdk = jdk11_headless;
    }) ];

    src = "${src}/app/server";

    buildPhase = ''
      mvn package -Dmaven.test.skip=true -DskipTests -Dmaven.repo.local=$out
    '';

    installPhase = ''
      find $out -type f -name \*.lastUpdated -delete
      find $out -type f -name resolver-status.properties -delete
      find $out -type f -name _remote.repositories -delete
    '';

    dontFixup = true;
    outputHashAlgo = "sha256";
    outputHashMode = "recursive";
    outputHash = "Avm3w3W/tJp0jvOXYUz7DwPgEsIeAVmARTUF/SWBYW0=";
  };
in stdenv.mkDerivation {
  name = "appsmith-server";
  inherit src;

  buildInputs = [ (maven.override {
    jdk = jdk11_headless;
  }) makeWrapper ];

  patches = [
    ./add_plugindir.patch
  ];

  buildPhase = ''
    cd app/server
    mvn package --offline -Dmaven.test.skip=true -DskipTests -Dmaven.repo.local=${deps}
  '';

  installPhase = ''
    mkdir -p $out/bin
    mkdir -p $out/share/java/plugins

    install -Dm644 appsmith-server/target/server-1.0-SNAPSHOT.jar $out/share/java/server.jar
    cp -rf appsmith-plugins/*/target/*.jar $out/share/java/plugins

    makeWrapper ${jdk11_headless}/bin/java $out/bin/appsmith-server --add-flags "-jar $out/share/java/server.jar"
  '';
}

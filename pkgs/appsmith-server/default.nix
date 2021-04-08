{stdenv,fetchMavenArtifact, fetchFromGitHub, maven, jdk11_headless, makeWrapper, ... }:

let
  src = fetchFromGitHub {
    owner = "appsmithorg";
    repo = "appsmith";
    rev = "v1.4.6";
    sha256 = "tnhzpX4KluOH41NXDDsbsbhTQYz+ghvU/OAgR8sEpQE=";
  };

  nimbusJoseJwtJar = fetchMavenArtifact {
    artifactId = "nimbus-jose-jwt";
    groupId = "com.nimbusds";
    version = "9.8";
    sha256 = "kJOqsSs360eseNOVY6VWD68C5TJQtmDS7VrhB5Wfh3w=";
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

      rm -rf $out/com/nimbusds/nimbus-jose-jwt/9.8.*
      cp ${./nimbus-jose-jwt-maven.xml} $out/com/nimbusds/nimbus-jose-jwt/maven-metadata-central.xml
      cp ${./nimbus-jose-jwt-maven.xml.sha1} $out/com/nimbusds/nimbus-jose-jwt/maven-metadata-central.xml.sha1
      cp ${nimbusJoseJwtJar}/share/java/nimbus-jose-jwt-9.8.jar $out/com/nimbusds/nimbus-jose-jwt/9.8/nimbus-jose-jwt-9.8.jar
    '';

    dontFixup = true;
    outputHashAlgo = "sha256";
    outputHashMode = "recursive";
    outputHash = "81v+hZ8Aao/W+i821ToeiajAdwthYi7pcifB3yiR2F4=";
  };

in 
  stdenv.mkDerivation {
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

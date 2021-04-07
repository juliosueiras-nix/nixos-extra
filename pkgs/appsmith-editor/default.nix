{ stdenv, fetchzip, ... }:

stdenv.mkDerivation {
  name = "appsmith-editor";
  src = fetchzip {
    url = "https://nightly.link/appsmithorg/appsmith/actions/artifacts/50436255.zip";
    sha256 = "uQSCrI7KBv/CMQYZr04OXa5uxfA099l7dmX1Yzp1nkc=";
    stripRoot = false;
  };

  installPhase = ''
    mkdir $out
    cp -rf * $out
  '';
}

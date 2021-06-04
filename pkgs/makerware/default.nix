with import <nixpkgs> { };

let
  urlPath = { package, version, path }:
    "http://downloads.makerbot.com/makerware/ubuntu/pool/main/${path}/${package}_${version}-16.04_amd64.deb";
  makerbotDep = { name, buildInputs, version, sha256, path ? "m/makerware"
    , installPhase ? null }:
    stdenv.mkDerivation {
      inherit name buildInputs version;

      src = fetchurl {
        url = urlPath {
          inherit version path;
          package = name;
        };
        inherit sha256;
      };

      unpackPhase = ''
        ${dpkg}/bin/dpkg-deb -xv $src .
      '';

      installPhase = if installPhase != null then
        installPhase
      else ''
        mkdir -p $out
        cp -r usr/* $out/
      '';
    };

in rec {
  libjsonrpc = makerbotDep {
    name = "mb-libjsonrpc";
    version = "3.9.1";
    sha256 = "D8anxtkukjEMq8lq7o1LPryFJx4mwTlz6IrH6OoLkxM=";

    buildInputs = [ autoPatchelfHook mb-libjsoncpp gcc.cc ];
  };
  libopenmesh = makerbotDep {
    name = "libopenmesh-3.2";
    version = "3.2";
    sha256 = "4HkpvorCYA0OSj8hUewYUS3nPS90Mb2iSf9RQ5OtraE=";

    path = "o/openmesh";

    buildInputs = [ autoPatchelfHook gcc.cc ];
  };
  fopenhack = makerbotDep {
    name = "mb-fopenhack";
    version = "3.9.1";
    sha256 = "YuDHeLOxQLBPyaB0ml1nYDleCGFp+iwHREjMn53MBHE=";

    buildInputs = [ autoPatchelfHook gcc.cc ];
  };
  libthing = makerbotDep {
    name = "libthing";
    version = "3.9.1";
    sha256 = "j4dEOu+J7F4u75KAZW4JYMGObO7rcfYiFO9f+ZMqXk4=";

    buildInputs = [
      autoPatchelfHook
      gcc.cc
      zlib
      mb-libjsoncpp
      libopenmesh
      fopenhack
      (boost159.overrideAttrs (oldAttrs: rec {
        name = "boost-${version}";
        version = "1.58.0";

        src = fetchurl {
          url = "mirror://sourceforge/boost/boost_1_58_0.tar.bz2";
          sha256 = "1rfkqxns60171q62cppiyzj8pmsbwp1l8jd7p6crriryqd7j1z7x";
        };
      }))
    ];
  };
  conveyor-common = makerbotDep {
    name = "conveyor-common";
    version = "3.9.1";
    sha256 = "yxHzfHZ0ChMaShpz+Zn+JN1BUY6EOFGdeBHK/hCFEOI=";

    buildInputs = [ autoPatchelfHook mb-libjsoncpp libjsonrpc gcc.cc python2 udev ];
  };

  conveyor = makerbotDep {
    name = "conveyor";
    version = "3.9.1";
    sha256 = "LtZ804tVr+9+MWHQ1OWfcmSgg9Qbzc2hLHuKXVYYLvA=";

    buildInputs = [ autoPatchelfHook ];
  };
  libmbqtutils = makerbotDep {
    name = "libmbqtutils";
    version = "3.9.1";
    sha256 = "4usqKNeA6FEyzumujgTJItuXlE4MULfAvJHDSoVOMms=";

    buildInputs = [
      autoPatchelfHook
      gcc.cc
      mb-libjsoncpp
      conveyor-common
      libthing
      libGL
      qt5.qtbase
      libtinything
    ];
  };

  libtinything = makerbotDep {
    name = "libtinything";
    version = "3.9.1";
    sha256 = "Xd+8ipm5JwDx1r0/0vlr6WdFbVEy/+FJYkwTsjBPf1E=";

    buildInputs = [ autoPatchelfHook gcc.cc ];
  };

  conveyor-ui = makerbotDep {
    name = "conveyor-ui";
    version = "3.9.1";
    sha256 = "eN18aF+BlQ0VH9OT/1PmslYN1KuIqUNk1WFWIFL28hg=";

    buildInputs =
      [ autoPatchelfHook gcc.cc mb-libjsoncpp qt5.qtbase conveyor-common ];
  };

  libtoolpathviz = makerbotDep {
    name = "libtoolpathviz";
    version = "3.9.1";
    sha256 = "dQ5uJsS3UGQkP5ZT7ebxI+hzHkvD91zN3a3jWwk7M4o=";

    buildInputs = [
      autoPatchelfHook
      gcc.cc
      libtinything
      libmbqtutils
      qt5.qtbase
      libGL
      mb-libjsoncpp
      conveyor-common
      yajl
    ];
  };

  miracle-grue = makerbotDep {
    name = "miracle-grue";
    version = "3.9.1";
    sha256 = "aNuc5q+SHkatVpvT638Wif80zVyFiAUFPgBgaR/zIo0=";

    buildInputs = [ 
      autoPatchelfHook
      libthing
      mb-libjsoncpp
      (boost159.overrideAttrs (oldAttrs: rec {
        name = "boost-${version}";
        version = "1.58.0";

        src = fetchurl {
          url = "mirror://sourceforge/boost/boost_1_58_0.tar.bz2";
          sha256 = "1rfkqxns60171q62cppiyzj8pmsbwp1l8jd7p6crriryqd7j1z7x";
        };
      }))
    ];
  };

  makerbot-driver = makerbotDep {
    name = "makerbot-driver";
    version = "3.9.1";
    sha256 = "tE04M07zMO75AwF4vliZa7kJaCi4QYO0sOiJ23F5n2A=";

    buildInputs = [ 
      autoPatchelfHook
    ];
  };

  croissant = makerbotDep {
    name = "croissant";
    version = "3.9.1";
    sha256 = "pQNg+jW+n9UagLuW7ay8XTmJsMWufaD7L0TNSJcgVKM=";

    buildInputs = [ 
      autoPatchelfHook
    ];
  };

  mb-pyserial = makerbotDep {
    name = "mb-pyserial";
    version = "3.9.1";
    sha256 = "jJ9/9tamQRP/JEmRnfVAF9dX1t4TZwKLwvo76j049wo=";

    buildInputs = [ 
      autoPatchelfHook
    ];
  };

  mb-pyusb = makerbotDep {
    name = "mb-pyusb";
    version = "3.9.1";
    sha256 = "CMGPkeZv0Ehs54tiFk1QoEAqNKrsXnHC0n99pbcG4bo=";

    buildInputs = [ 
      autoPatchelfHook
    ];
  };

  mb-toolchainrelease-dev = makerbotDep {
    name = "mb-toolchainrelease-dev";
    version = "3.9.1";
    sha256 = "SahSdNX5HK3cdI0GTBSq6UUkIBz0Ms0HcWL3ZLWX4iI=";

    buildInputs = [ 
      autoPatchelfHook
    ];
  };

  mbcoreutils = makerbotDep {
    name = "mbcoreutils";
    version = "3.9.1";
    sha256 = "JCy0pRTKTRpkJcM8XsTsnNG2fXYR25TKjIRQQDbegEk=";

    buildInputs = [ 
      autoPatchelfHook
    ];
  };

  mbacceleration = makerbotDep {
    name = "mbacceleration";
    version = "3.9.1";
    sha256 = "BR/i8U0Na4obtr2yo2VdhyNw9/9IsEb8cbvPC7WWO+U=";

    buildInputs = [ 
      autoPatchelfHook
      mb-libjsoncpp
      libtinything
      yajl
      gcc.cc
      (boost159.overrideAttrs (oldAttrs: rec {
        name = "boost-${version}";
        version = "1.58.0";

        src = fetchurl {
          url = "mirror://sourceforge/boost/boost_1_58_0.tar.bz2";
          sha256 = "1rfkqxns60171q62cppiyzj8pmsbwp1l8jd7p6crriryqd7j1z7x";
        };
      }))
    ];
  };

  mb-libjsoncpp = makerbotDep {
    name = "mb-libjsoncpp";
    version = "3.9.1";
    sha256 = "npS7YXcxeatjDeprvLjKW26p4WsJ50f1gnegGV4QHXQ=";

    buildInputs = [ 
      autoPatchelfHook
      gcc.cc
    ];
  };

  eggs-benedict = makerbotDep {
    name = "eggs-benedict";
    version = "3.9.1";
    sha256 = "4Wdf8jEJxULPLQStzdsNOKy6IIx3CGE7WQBTln6kfDQ=";

    buildInputs = [ 
      autoPatchelfHook
    ];
  };

  makerware = makerbotDep {
    name = "makerware";
    version = "3.9.1";
    sha256 = "lOMJ1JypLEpYr6Gszu0NfGgMbDugoJ2q20aArmMuAz8=";

    buildInputs = [
      autoPatchelfHook
      libGL
      dbus
      libtoolpathviz
      libthing
      conveyor-ui
      qt5.qtbase
      qt5.qtmultimedia
      qt5.qtwebkit
      libjson
      libjsonrpc
      gksu
      gcc.cc
      zlib
      libmbqtutils
      qt5.wrapQtAppsHook
    ];
  };
}

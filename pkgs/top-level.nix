{ callPackage, ... }:

{
  valheim-server = callPackage ./valheim-server {};
  appsmith-editor = callPackage ./appsmith-editor {};
  appsmith-server = callPackage ./appsmith-server {};
}

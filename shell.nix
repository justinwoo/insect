{ pkgs ? import <nixpkgs> {} }:

let
  easy-ps = import (
    pkgs.fetchFromGitHub {
      owner = "justinwoo";
      repo = "easy-purescript-nix";
      rev = "01ae1bc844a4eed1af7dfbbb202fdd297e3441b9";
      sha256 = "0jx4xb202j43c504gzh27rp9f2571ywdw39dqp6qs76294zwlxkh";
    }
  ) {
    inherit pkgs;
  };

  soba = import (
    pkgs.fetchFromGitHub {
      owner = "justinwoo";
      repo = "soba";
      rev = "90724e5d5658b694d5531d40a1be668e9ef56790";
      sha256 = "15yj59dhid8dwgkp2c2x5v5h8kdpc4ixhkhxx9k8miyx4xpvmm0f";
    }
  ) {
    inherit pkgs;
  };

  purs-packages = import ./purs-packages.nix { inherit pkgs; };

  cpPackage = pp:
    let
      target = ".psc-package/local/${pp.name}/${pp.version}";
    in
      ''
        mkdir -p ${target}
        cp --no-preserve=mode,ownership,timestamp -r ${pp.fetched.outPath}/* ${target}
      '';

  install-purs-packages = pkgs.runCommand "install-purs-packages" {} ''
    mkdir -p $out/bin
    target=$out/bin/install-purs-packages
    touch $target
    chmod +x $target
    >>$target echo '#!/usr/bin/env bash'
    >>$target echo '${builtins.toString (builtins.map cpPackage (builtins.attrValues purs-packages))}'
    >>$target echo 'echo done installing deps.'
  '';

  build-purs = pkgs.runCommand "build-purs" {} ''
    mkdir -p $out/bin
    target=$out/bin/build-purs
    touch $target
    chmod +x $target
    >>$target echo '#!/usr/bin/env bash'
    >>$target echo 'purs compile ".psc-package/*/*/*/src/**/*.purs" "src/**/*.purs"'
  '';

  storePath = x: ''"${x.fetched.outPath}/src/**/*.purs"'';

  build-purs-from-store = pkgs.runCommand "build-purs-from-store" {} ''
    mkdir -p $out/bin
    target=$out/bin/build-purs-from-store
    touch $target
    chmod +x $target
    >>$target echo '#!/usr/bin/env bash'
    >>$target echo 'purs compile ${builtins.toString (builtins.map storePath (builtins.attrValues purs-packages))} "src/**/*.purs"'
  '';

in
pkgs.mkShell {
  buildInputs = [
    easy-ps.purs
    easy-ps.psc-package-simple
    soba
    install-purs-packages
    build-purs
    build-purs-from-store
  ];
}

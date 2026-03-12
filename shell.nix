{ pkgs }:
pkgs.mkShell {
  buildInputs = with pkgs; [
    zensical
  ];

  shellHook = ''
  '';
}

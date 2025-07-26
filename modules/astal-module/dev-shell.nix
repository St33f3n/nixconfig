{ pkgs, astal, system ? "x86_64-linux" }:

let
  astalPackages = with astal.packages.${system}; [
    io astal4 battery wireplumber network tray bluetooth mpris
  ];
in
pkgs.mkShell {
  packages = with pkgs; [
    gjs
    gtk4
    gobject-introspection
    typescript-language-server  # für LSP
    nodejs_24                   # für package management falls nötig
  ] ++ astalPackages ++ [
    astal.packages.${system}.default  # astal CLI
  ];

  shellHook = ''
    echo "🚀 Astal Development Environment"
    echo "Available commands:"
    echo "  astal --help          # Astal CLI"
    echo "  gjs --help           # JavaScript runtime"
    echo "  astal --list         # List running instances"
    echo ""
    echo "Environment variables:"
    echo "  GI_TYPELIB_PATH=${pkgs.lib.makeSearchPath "lib/girepository-1.0" (astalPackages ++ [ pkgs.gtk4 pkgs.glib ])}"
    
    export GI_TYPELIB_PATH="${pkgs.lib.makeSearchPath "lib/girepository-1.0" (astalPackages ++ [ pkgs.gtk4 pkgs.glib ])}"
    export LD_LIBRARY_PATH="${pkgs.lib.makeLibraryPath (astalPackages ++ [ pkgs.gtk4 pkgs.glib ])}"
  '';
}

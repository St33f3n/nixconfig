{
  pkgs,
  astal,
  system ? "x86_64-linux",
}:

let
  astalPackages = with astal.packages.${system}; [
    io
    astal4
    battery
    wireplumber
    network
    tray
    bluetooth
    mpris
  ];

  # 🔥 Explizite GObject typelib packages
  coreGIPackages = with pkgs; [
    # Core GObject system - diese MÜSSEN verfügbar sein
    gobject-introspection
    glib.out # Runtime glib

    # GTK stack
    gtk4
    gtk3
    gdk-pixbuf
    cairo.out
    pango.out
    harfbuzz
    atk
    at-spi2-core
    graphene
    libgudev
  ];

  # Typelib paths - nur die die existieren
  validTypelibPaths =
    builtins.filter (path: builtins.pathExists path) [
      # System core typelibs - müssen als erstes kommen
      "${pkgs.gobject-introspection}/lib/girepository-1.0"
      "${pkgs.glib.out}/lib/girepository-1.0"

      # GTK stack
      "${pkgs.gtk4}/lib/girepository-1.0"
      "${pkgs.gtk3}/lib/girepository-1.0"
      "${pkgs.gdk-pixbuf}/lib/girepository-1.0"
      "${pkgs.pango.out}/lib/girepository-1.0"
      "${pkgs.harfbuzz}/lib/girepository-1.0"
      "${pkgs.atk}/lib/girepository-1.0"
      "${pkgs.at-spi2-core}/lib/girepository-1.0"
      "${pkgs.graphene}/lib/girepository-1.0"
      "${pkgs.libgudev}/lib/girepository-1.0"

      # Astal packages (am Ende)
    ]
    ++ (map (pkg: "${pkg}/lib/girepository-1.0") astalPackages);

in
pkgs.mkShell {
  packages =
    with pkgs;
    [
      gjs
      pkg-config
      entr

      # Core GI system
      gobject-introspection
      glib

    ]
    ++ coreGIPackages
    ++ astalPackages;

  shellHook = ''
    echo "🔧 Astal Development Environment (GObject Fixed)"

    # 🔥 Nur valide Pfade verwenden
    export GI_TYPELIB_PATH="${builtins.concatStringsSep ":" validTypelibPaths}"

    # System fallback für fehlende typelibs
    for syspath in /usr/lib/girepository-1.0 /usr/lib64/girepository-1.0 /usr/lib/x86_64-linux-gnu/girepository-1.0; do
      if [ -d "$syspath" ]; then
        export GI_TYPELIB_PATH="$GI_TYPELIB_PATH:$syspath"
        echo "📁 Added system path: $syspath"
      fi
    done

    echo ""
    echo "🔍 Critical typelib check:"

    # Check für die wichtigsten typelibs
    for typelib in "GObject-2.0" "Gio-2.0" "Gtk-4.0" "Astal-4.0"; do
      found=false
      IFS=':' read -ra PATHS <<< "$GI_TYPELIB_PATH"
      for path in "''${PATHS[@]}"; do
        if [ -f "$path/$typelib.typelib" ]; then
          echo "✅ $typelib.typelib found in $path"
          found=true
          break
        fi
      done
      if [ "$found" = false ]; then
        echo "❌ $typelib.typelib NOT FOUND"
      fi
    done

    echo ""
    echo "🧪 Testing basic imports:"
    gjs -c 'try { const GObject = imports.gi.GObject; print("✅ GObject imported") } catch(e) { print("❌ GObject:", e.message) }'
    gjs -c 'try { const Gio = imports.gi.Gio; print("✅ Gio imported") } catch(e) { print("❌ Gio:", e.message) }'
    gjs -c 'try { imports.gi.versions.Gtk="4.0"; const Gtk = imports.gi.Gtk; print("✅ Gtk4 imported") } catch(e) { print("❌ Gtk4:", e.message) }'

    echo ""
    echo "📋 Commands:"
    echo "  gjs test-core.js        # Test core GObject functionality"
    echo "  gjs app-basic.js        # Basic Gtk4 app"
  '';
}

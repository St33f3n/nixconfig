{ pkgs, astal, ags }:
let
  system = "x86_64-linux";
in
pkgs.stdenvNoCC.mkDerivation rec {
  name = "my-shell";
  src = ./.;

  nativeBuildInputs = with pkgs; [
    nodejs_24
    esbuild
    wrapGAppsHook
    gobject-introspection
  ];

  buildInputs = with pkgs; [
    gjs
    glib  
    gtk4
    gtk3
    gdk-pixbuf
    cairo
    pango
  ] ++ [
    astal.packages.${system}.astal4
    astal.packages.${system}.io
    astal.packages.${system}.tray
    astal.packages.${system}.wireplumber
    astal.packages.${system}.network
    astal.packages.${system}.bluetooth
    astal.packages.${system}.battery
  ];

  buildPhase = ''
    # Create basic app structure if not exists
    if [ ! -f src/app.ts ]; then
      mkdir -p src
      cat > src/app.ts << 'EOF'
import { App } from "astal/gtk4"
import Bar from "./bar"

App.start({
    css: "./style.css",
    main: () => App.get_monitors().map(Bar),
})
EOF

      cat > src/bar.ts << 'EOF'
import { Variable, bind } from "astal"
import { Astal, Gtk, Gdk } from "astal/gtk4"

function time() {
    const time = Variable("").poll(1000, () => 
        new Date().toLocaleTimeString())
    
    return <label label={bind(time)} />
}

export default function Bar(monitor: Gdk.Monitor) {
    return <window
        className="Bar"
        monitor={monitor}
        exclusivity={Astal.Exclusivity.EXCLUSIVE}
        anchor={Astal.WindowAnchor.TOP | Astal.WindowAnchor.LEFT | Astal.WindowAnchor.RIGHT}
        application={App}>
        <centerbox>
            <box />
            <box>{time()}</box>
            <box />
        </centerbox>
    </window>
}
EOF

      cat > style.css << 'EOF'
.Bar {
    background-color: rgba(0, 0, 0, 0.8);
    color: white;
    padding: 8px;
}
EOF
    fi
  '';

  installPhase = ''
    mkdir -p $out/bin $out/share/my-shell

    # Copy source files  
    cp -r src $out/share/my-shell/
    cp style.css $out/share/my-shell/ || true

    # Bundle with esbuild
    ${pkgs.esbuild}/bin/esbuild \
      --bundle src/app.ts \
      --outfile=$out/bin/my-shell \
      --format=esm \
      --platform=node \
      --target=node18 \
      --external:gi://* \
      --external:resource://* \
      --jsx-factory=jsx \
      --jsx-fragment=Fragment

    # Make executable
    chmod +x $out/bin/my-shell
  '';

  meta = with pkgs.lib; {
    description = "Custom Astal desktop shell";
    platforms = platforms.linux;
  };
}

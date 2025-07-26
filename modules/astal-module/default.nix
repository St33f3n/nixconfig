{ pkgs, astal ? null, system ? "x86_64-linux" }:

# Fallback falls astal nicht verfügbar
if astal == null then pkgs.hello else

let
  astalPackages = with astal.packages.${system}; [
    io
    astal4
    battery
    wireplumber
    network
    tray
  ];
in
pkgs.stdenv.mkDerivation {
  name = "astal-shell";
  
  # Kein src nötig - wir erstellen alles in buildPhase
  unpackPhase = "true";  # Skip unpack
  
  nativeBuildInputs = with pkgs; [
    wrapGAppsHook4
    gobject-introspection
  ];
  
  buildInputs = astalPackages ++ [ pkgs.gjs ];

  buildPhase = ''
    mkdir -p app
    cd app
    
    # JavaScript App erstellen
    cat > app.js << 'EOF'
import { App } from "gi://Astal?version=4.0"
import { Variable, bind } from "gi://Astal?version=4.0"
import { Astal, Gtk } from "gi://Astal?version=4.0"

function createClock() {
    const time = Variable("").poll(1000, () => 
        new Date().toLocaleTimeString("de-DE"))
    
    const label = new Gtk.Label()
    bind(time).subscribe(t => label.set_text(t))
    return label
}

function createBar(monitor) {
    const window = new Astal.Window({
        className: "NeptuneBar",
        monitor: monitor,
        exclusivity: Astal.Exclusivity.EXCLUSIVE,
        anchor: Astal.WindowAnchor.TOP | 
               Astal.WindowAnchor.LEFT | 
               Astal.WindowAnchor.RIGHT,
    })
    
    const centerbox = new Gtk.CenterBox()
    centerbox.set_center_widget(createClock())
    
    window.set_child(centerbox)
    window.show()
}

App.start({
    main() {
        App.get_monitors().forEach(createBar)
    }
})
EOF

    # CSS erstellen
    cat > style.css << 'EOF'
.NeptuneBar {
    background-color: rgba(32, 45, 54, 0.95);
    color: #e6f3f7;
    padding: 8px;
    font-family: "MartianMono Nerd Font";
}
EOF
  '';

  installPhase = ''
    mkdir -p $out/bin $out/share/astal-shell
    
    # JavaScript files installieren
    cp app.js $out/share/astal-shell/
    cp style.css $out/share/astal-shell/
    
    # Launcher script erstellen
    cat > $out/bin/astal-shell << 'EOF'
#!/usr/bin/env gjs
imports.gi.versions.Gtk = "4.0"
imports.gi.versions.Astal = "4.0"

import("file://$\{out\}/share/astal-shell/app.js")
EOF
    
    chmod +x $out/bin/astal-shell
  '';
  
  # Skip configure phase completely
  dontConfigure = true;
}

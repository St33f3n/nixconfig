{ lib, stdenv, fetchurl, autoPatchelfHook, makeWrapper, wrapGAppsHook

# Runtime dependencies
, gtk3, glib, alsa-lib, dbus-glib, libxcb, libXcomposite, libXdamage, libXrandr
, mesa, libGL, nss, nspr, openssl, ffmpeg, pipewire, at-spi2-atk, cups, libdrm
, libxkbcommon, libXScrnSaver, libXtst, libudev0-shim }:

stdenv.mkDerivation rec {
  pname = "zen-browser";
  version = "1.12b";

  src = fetchurl {
    url =
      "https://github.com/zen-browser/desktop/releases/download/${version}/zen.linux-x86_64.tar.xz";
    sha256 = "1vsyqjy3ivixxfcz81rr61ab5gs4v5q93jbfj7ga1rgsx7p9zakn";
  };

  nativeBuildInputs = [
    autoPatchelfHook # Automatically patches ELF binaries
    makeWrapper # For creating wrapper scripts
    wrapGAppsHook # GTK application wrapping
  ];

  buildInputs = [
    # GUI & Windowing (your questions about X11/Wayland)
    gtk3
    glib
    libxcb
    libXcomposite
    libXdamage
    libXrandr
    libxkbcommon
    libXScrnSaver
    libXtst

    # Audio (alsa + modern pipewire)
    alsa-lib
    pipewire

    # Graphics & Rendering (your WebGL intuition!)
    mesa
    libGL
    libdrm

    # Security & Crypto (your openssl insight!)
    nss
    nspr
    openssl

    # System Integration (your dbus knowledge!)
    dbus-glib
    at-spi2-atk
    cups
    libudev0-shim

    # Media (your ffmpeg understanding!)
    ffmpeg
  ];

  # No build phase needed - we have pre-built binaries!
  dontBuild = true;
  dontConfigure = true;

  installPhase = ''
        runHook preInstall

        # Create output directories
        mkdir -p $out/bin $out/lib $out/share

        # Copy all browser files to lib directory
        cp -r . $out/lib/zen-browser/

        # Create symlink in bin (your symlink insight!)
        ln -s $out/lib/zen-browser/zen $out/bin/zen

        # Install desktop entry for system integration
        mkdir -p $out/share/applications
        cat > $out/share/applications/zen-browser.desktop << EOF
    [Desktop Entry]
    Version=1.0
    Name=Zen Browser
    Comment=Experience tranquillity while browsing the web
    GenericName=Web Browser
    Keywords=Internet;WWW;Browser;Web;Explorer
    Exec=zen %U
    Terminal=false
    X-MultipleArgs=false
    Type=Application
    Icon=$out/lib/zen-browser/browser/chrome/icons/default/default128.png
    Categories=GNOME;GTK;Network;WebBrowser;
    MimeType=text/html;text/xml;application/xhtml+xml;application/xml;application/rss+xml;application/rdf+xml;image/gif;image/jpeg;image/png;x-scheme-handler/http;x-scheme-handler/https;x-scheme-handler/ftp;x-scheme-handler/chrome;video/webm;application/x-xpinstall;
    StartupNotify=true
    EOF

        runHook postInstall
  '';

  # Fix library paths and environment
  postFixup = ''
    # The autoPatchelfHook handles most of this automatically!
    # But we can add extra environment setup if needed
    wrapProgram $out/bin/zen \
      --set-default MOZ_ENABLE_WAYLAND 1 \
      --set-default MOZ_USE_XINPUT2 1
  '';

  meta = with lib; {
    description = "Experience tranquillity while browsing the web";
    homepage = "https://zen-browser.app";
    license = licenses.mpl20;
    maintainers = [ maintainers.yourname ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "zen";
  };
}

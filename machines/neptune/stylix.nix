{ pkgs, inputs, ... }:
let
  # ============================================================================
  # FARBSCHEMA - Ocean Coral Theme
  # ============================================================================
  # Base16 Farbschema mit warmen Beige-Tönen und Meeresthema
  # Inspiriert von Korallenriffen und Meeresfarben
  
  color_scheme = {
    # Hintergrundfarben
    base00 = "1e1e1e"; # Default Background (abyss - dunkles Anthrazit)
    base01 = "262626"; # Lighter Background (deep-water - für Status Bars)
    base02 = "6b8e6b"; # Selection Background (sea-foam morandi green)
    base03 = "4a4a4a"; # Comments, Invisibles (normal black - heller für Sichtbarkeit)
    
    # Vordergrundfarben
    base04 = "c4b89f"; # Dark Foreground (text-muted warm beige)
    base05 = "f7f2e3"; # Default Foreground (text-primary warm beige)
    base06 = "f7f2e3"; # Light Foreground (bright_foreground)
    base07 = "ffffff"; # Light Background (white bright)
    
    # Syntax-Highlighting Farben
    base08 = "c84a2c"; # Variables/Red (coral-red dimmed)
    base09 = "d49284"; # Integers/Orange (coral-light dimmed)
    base0A = "d49284"; # Classes/Yellow (coral-light dimmed)
    base0B = "6b8e6b"; # Strings/Green (sea-foam morandi green)
    base0C = "5a9a9a"; # Support/Cyan (bioluminescent morandi teal)
    base0D = "c4b89f"; # Functions/Blue (coral-blue softer)
    base0E = "b85347"; # Keywords/Magenta (coral-deep dimmed)
    base0F = "8a9a8a"; # Deprecated (seafoam-gray)
  };

  # ============================================================================
  # WALLPAPER KONFIGURATION
  # ============================================================================
  # Wallpaper von Nextcloud - Nature Theme
  
  imgLink = "https://nextcloud.organiccircuitlab.com/s/e49P655iKfLAXnw/download/nature.jpg";

  image = pkgs.fetchurl {
    url = imgLink;
    sha256 = "1dsclng2cak245hj5c9hf014ynywc8gb0xrv2kb75anjgzj0s88p";
  };

in
{
  # ============================================================================
  # STYLIX HAUPTKONFIGURATION
  # ============================================================================
  # Aktiviert automatisches Theming für alle unterstützten Anwendungen
  
  stylix.autoEnable = true;
  stylix.targets.gtk.enable = true;
  stylix.targets.qt.enable = true;
  stylix.base16Scheme = color_scheme;
  stylix.image = image;

  home-manager.sharedModules = [
  {
    stylix.targets.rofi.enable = false;
  }
];

  # Wallpaper-Einstellungen für Ultra-Wide-Monitor optimiert
  stylix.imageScalingMode = "fill"; # Füllt den gesamten Bildschirm aus
  stylix.polarity = "dark"; # Dunkles Theme

  # ============================================================================
  # CURSOR KONFIGURATION
  # ============================================================================
  # Qogir Dark Cursor Theme für einheitliches Erscheinungsbild
  
  stylix.cursor.package = pkgs.qogir-icon-theme;
  stylix.cursor.name = "Qogir-Dark";
  stylix.cursor.size = 24;

  # ============================================================================
  # SCHRIFTARTEN KONFIGURATION
  # ============================================================================
  # Alle Schriftarten verwenden Nerd Fonts für konsistente Icon-Unterstützung
  
  stylix.fonts = {
    # Monospace - Für Terminal und Code-Editor
    monospace = {
      package = pkgs.nerd-fonts.martian-mono;
      name = "MartianMono Nerd Font";
    };
    
    # Sans-Serif - Für UI-Elemente und allgemeine Texte
    sansSerif = {
      package = pkgs.nerd-fonts.fira-code;
      name = "FiraCode Nerd Font";
    };
    
    # Serif - Für Dokumente und formelle Texte
    serif = {
      package = pkgs.nerd-fonts.fira-code;
      name = "FiraCode Nerd Font";
    };
    
    # Emoji - Für Emoji-Unterstützung
    emoji = {
      package = pkgs.noto-fonts-emoji;
      name = "Noto Color Emoji";
    };
  };

  # ============================================================================
  # SYSTEM PACKAGES
  # ============================================================================
  # Qt-Theming Tools für vollständige Desktop-Integration
  
  environment.systemPackages = with pkgs; [
    libsForQt5.qt5ct      # Qt5 Konfigurations-Tool
    qt6ct                 # Qt6 Konfigurations-Tool
    libsForQt5.qtstyleplugins # Qt Style Plugins
  ];

  # ============================================================================
  # SYSTEM SERVICES
  # ============================================================================
  # Farbmanagement-Dienst für korrekte Farbdarstellung
  
  services.colord.enable = true;
  
  # ============================================================================
  # UMGEBUNGSVARIABLEN
  # ============================================================================
  # Cursor und Farbschema für alle Anwendungen verfügbar machen
  
  environment.sessionVariables = {
    # X11 Cursor Einstellungen
    XCURSOR_THEME = "Qogir-Dark";
    XCURSOR_SIZE = "24";
    
    # Hyprland Cursor Einstellungen
    HYPRCURSOR_THEME = "Qogir-Dark";
    HYPRCURSOR_SIZE = "24";

    # Wayland Display
    WAYLAND_DISPLAY = "wayland-0";
    
    # Farbschema als JSON exportieren für Custom Scripts
    COLORSCHEME = builtins.toJSON color_scheme;
  };
}

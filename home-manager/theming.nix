{pkgs, ...}: {
  gtk = {
    enable = true;
    theme.package = pkgs.qogir-theme;
    theme.name = "Qogir-Dark";
    cursorTheme.package = pkgs.qogir-icon-theme;
    cursorTheme.name = "Qogir-dark";
    iconTheme.package = pkgs.qogir-icon-theme;
    iconTheme.name = "Qogir-dark";

  };

  qt = {
    enable = true;
    platformTheme.name = "qt5ct";
    
  };

  home.sessionVariables={
    GTK_THEME = "Qogir-Dark";
  };
}

{pkgs}: let
  imgLink = "https://nextcloud.organiccircuitlab.com/s/54nX4WDM8j2e8jo/download/current.jpg";

  image = pkgs.fetchurl {
    url = imgLink;
    sha256 = "1jyvzxic83pb6hscvx4kszp49b96vaczj7040i5y0dkalc46rz93";
  };
in
  pkgs.stdenv.mkDerivation {
    name = "sddm-theme";
    src = pkgs.fetchFromGitHub {
      owner = "MarianArlt";
      repo = "sddm-sugar-dark";
      rev = "ceb2c455663429be03ba62d9f898c571650ef7fe";
      sha256 = "0153z1kylbhc9d12nxy9vpn0spxgrhgy36wy37pk6ysq7akaqlvy";
    };
    installPhase = ''
      mkdir -p $out
      cp -R ./* $out/
      cd $out/
      rm Background.jpg
      cp -r ${image} $out/Background.jpg
    '';
  }

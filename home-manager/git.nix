{
  config,
  pkgs,
  inputs,
  ...
}: {
  programs.git = {
    enable = true;
    package = pkgs.gitAndTools.gitFull;
    extraConfig = {
      credential.helper = "${pkgs.git.override {withLibsecret = true;}}/bin/git-credential-libsecret";
    };
    userName = "Stefan Simmeth";
    userEmail = "stefan.simmeth@protonmail.com";
  };

}

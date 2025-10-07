# modules/kubernetes/default.nix
{
  imports = [
    ./base.nix
    ./master.nix
    ./worker.nix
  ];
}
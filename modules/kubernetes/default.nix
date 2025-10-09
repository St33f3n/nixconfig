# modules/kubernetes/default.nix
{
  imports = [
    ./nfs.nix
    ./master.nix
    ./worker.nix
  ];
}
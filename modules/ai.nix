# modules/ai.nix
{ config, lib, pkgs, ... }:

with lib;

{
  options.ai = {
    enable = mkEnableOption "AI and machine learning tools";
  };

  config = mkIf config.ai.enable {
    environment.systemPackages = with pkgs; [
      # AI Tools
      fabric-ai
      ollama
      
      # NVIDIA CUDA Support
      nvidia-container-toolkit
      cudaPackages.cudatoolkit
    ];
    
    # Enable CUDA support
    nixpkgs.config.allowUnfree = true;
    nixpkgs.config.cudaSupport = true;
  };
}

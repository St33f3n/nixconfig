# modules/ai.nix
{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

{
  options.ai = {
    enable = mkEnableOption "AI and machine learning tools";
  };

  config = mkIf config.ai.enable {
    environment.systemPackages = with pkgs; [
      # AI Tools
#      fabric-ai
      whisperx
      

      # NVIDIA CUDA Support
      nvidia-container-toolkit
      cudaPackages.cudatoolkit
    ];

    # Enable CUDA support
    nixpkgs.config.allowUnfree = true;
#    nixpkgs.config.cudaSupport = true;
    hardware.nvidia-container-toolkit.enable = true;
    services.ollama.acceleration = "rocm";
    services.ollama.enable = true;
    services.ollama.environmentVariables = { HIP_VISIBLE_DEVICES = "0"; OLLAMA_LLM_LIBRARY = "rocm"; };    
  
  };


  

  
}

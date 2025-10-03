# ai.nix - AI and Machine Learning Tools

{ config, lib, pkgs, ... }:

with lib;

{
  options.ai = {
    enable = mkEnableOption "AI and machine learning tools";
  };

  config = mkIf config.ai.enable {
    environment.systemPackages = with pkgs; [
      # AI Tools
      # fabric-ai

      # NVIDIA CUDA Support
      nvidia-container-toolkit
      cudaPackages.cudatoolkit
    ];

    # Enable CUDA support
    nixpkgs.config.allowUnfree = true;
    # nixpkgs.config.cudaSupport = true;

    # Hardware Support
    hardware.nvidia-container-toolkit.enable = true;

    # Ollama Configuration
    services.ollama = {
      enable = true;
      acceleration = "rocm";
      environmentVariables = {
        HIP_VISIBLE_DEVICES = "0";
        OLLAMA_LLM_LIBRARY = "rocm";
      };
    };
  };
}
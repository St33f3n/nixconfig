{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  packages = [
    (pkgs.python312.withPackages(p: with p; [
      pyside6
      faster-whisper
      langchain
      langchain-openai
      langchain-anthropic
      langchain-google-genai
      langchain-community
      pydantic
      pyyaml
      keyring
      psutil
      loguru
      webdav4
    ]))
    
    pkgs.cudaPackages.cudatoolkit
    pkgs.cudaPackages.cudnn
    pkgs.qt6.qtbase
    pkgs.ffmpeg
    pkgs.yt-dlp
  ];


    LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath [
    pkgs.cudaPackages.cudatoolkit
    pkgs.cudaPackages.cudnn
  ];

	  shellHook = ''
    echo "🌊 YouTube Analyzer Shell - $(python --version)"
    
    # Quick CUDA check
    if nvidia-smi &>/dev/null; then
      GPU=$(nvidia-smi --query-gpu=name --format=csv,noheader | head -1)
      echo "🚀 CUDA: $GPU"
      
      # Test faster-whisper CUDA
      WHISPER_STATUS=$(python -c "
from faster_whisper import WhisperModel
try:
    WhisperModel('tiny', device='cuda', compute_type='float16')
    print('✅ Ready for GPU transcription')
except: print('⚠️  GPU detected, CPU fallback available')
" 2>/dev/null)
      echo "$WHISPER_STATUS"
    else
      echo "💻 CPU-only mode (no NVIDIA GPU)"
    fi
    
    echo "▶️  python youtube_analyzer.py"
  '';
  
}

{
  lib,
  stdenv,
  fetchgit,
  
  # Build tools that Betterbird script expects
  git,
  python3,
  mercurial,
  curl,
  rustc,
  cargo,
  rustPlatform,
  
  # System dependencies (from apt-get install list)
  libdbusmenu-gtk3,
  pkg-config,
  
  # Additional Mozilla build deps (you may need more)
  nodejs,
  unzip,
  zip,
  which,
  autoconf,
  perl,
  yasm,
  makeWrapper,
}:

stdenv.mkDerivation rec {
  pname = "betterbird-unwrapped";
  version = "128.11.0esr-bb28";

  # Get the Betterbird patches repository
  src = fetchgit {
    url = "https://github.com/Betterbird/thunderbird-patches.git";
    # We'll need to find the right commit for this version
    rev = "HEAD";  # TODO: pin to specific commit
    sha256 = "1grmjnvriia04f3dkqj2b03b9wh7jgb9px2gniz00w1il9v1dy89";  # This will fail first, giving us the real hash
  };

  nativeBuildInputs = [
    git
    python3
    mercurial
    curl
    rustc
    cargo
    pkg-config
    nodejs
    unzip
    zip
    which
    autoconf
    perl
    yasm
    makeWrapper
  ];

  buildInputs = [
    libdbusmenu-gtk3
    # TODO: Add more dependencies as we discover them
  ];

  # Disable network access during build - this will likely fail initially
  # We'll need to pre-fetch the Mozilla repos instead
  __noChroot = false;

  configurePhase = ''
    echo "======================================================="
    echo "Setting up Betterbird build environment"
    echo "======================================================="
    
    # The build script expects to be in a directory with thunderbird-patches
    mkdir -p build-env
    cd build-env
    
    # Copy the patches repo
    cp -r $src thunderbird-patches
    chmod -R +w thunderbird-patches
    
    # Copy the build script
    cp thunderbird-patches/build/build.sh .
    chmod +x build.sh
    
    # Set up build environment variables
    export HOME=$TMPDIR
    export MOZBUILD_STATE_PATH=$TMPDIR/.mozbuild
  '';

  buildPhase = ''
    echo "======================================================="
    echo "Starting Betterbird build"
    echo "======================================================="
    
    # This will likely fail on the first attempt because:
    # 1. It tries to download Mozilla repos
    # 2. It needs specific Rust version
    # 3. It runs ./mach bootstrap which tries to install things
    
    # For now, let's just see what happens
    ./build.sh ${version} || echo "Build failed as expected - we need to debug"
  '';

  installPhase = ''
    echo "======================================================="
    echo "Packaging Betterbird"
    echo "======================================================="
    
    # TODO: Find where the built application ends up and copy it to $out
    mkdir -p $out
    echo "Install phase - to be implemented after build works"
  '';

  meta = with lib; {
    description = "Betterbird is a fine-tuned version of Mozilla Thunderbird";
    homepage = "https://www.betterbird.eu/";
    license = licenses.mpl20;
    maintainers = [ ];  # Add yourself here
    platforms = platforms.linux;
  };
}

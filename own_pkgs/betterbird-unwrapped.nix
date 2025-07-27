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
  fetchhg,
  bash,

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
    rev = "c347e8755585ca34b81312629741fc4c6ac0372b"; # TODO: pin to specific commit
    sha256 = "1v7whv79q2iswbkdhpwb3b68wv2y9ryvw9lxr2641b0qsnv2b9vf"; # Replace with the real hash you got
  };

  # Pre-fetch Mozilla repositories that Betterbird needs
  # These values come from thunderbird-patches/128/128.sh
  mozillaRepo = fetchhg {
    url = "https://hg.mozilla.org/releases/mozilla-esr128/";
    rev = "c6fae8e73635b58fac8a4536e34f63c8518a350d"; # MOZILLA_REV from 128.sh
    sha256 = "1gbpfpchhxcy0cnmhs1sbw1in20wisirmlx0wz71r7k34dsylzyf"; # We'll get the real hash from the build failure
  };

  commRepo = fetchhg {
    url = "https://hg.mozilla.org/releases/comm-esr128/";
    rev = "3abba23fa667473fade7fe4c44e2b8d25dba5fd1"; # COMM_REV from 128.sh
    sha256 = "1rq4xv14g4wr66wvr0b2wan84q6wkhfz3f3z165rbgcl5x5mcn0z";
  };

  # Note: 128.sh also specifies RUST_VER=1.79.0 - we might need to pin Rust version later

  nativeBuildInputs = [
    bash
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

    # Pre-place Mozilla repositories so script doesn't need to clone them
    echo "Setting up pre-fetched Mozilla repositories..."

    # The script expects mozilla-esr128 directory
    cp -r ${mozillaRepo} mozilla-esr128
    chmod -R +w mozilla-esr128

    # The script expects comm subdirectory inside mozilla repo
    mkdir -p mozilla-esr128/comm
    cp -r ${commRepo}/* mozilla-esr128/comm/
    chmod -R +w mozilla-esr128/comm

    echo "Directory structure after setup:"
    ls -la .
    echo "Mozilla directory contents:"
    ls -la mozilla-esr128/ | head -10
    echo "Comm directory contents:"
    ls -la mozilla-esr128/comm/ | head -5

    # Copy the build script and patch it more carefully
    cp thunderbird-patches/build/build.sh .
    chmod +x build.sh

    echo "Applying minimal patches to build.sh..."

    # 1. Disable git pull
    sed -i 's/^git pull/#git pull # Disabled for Nix/' build.sh

    # 2. Disable version check
    sed -i 's/^DIFF=$(diff -q build.sh/#DIFF=$(diff -q build.sh # Disabled for Nix/' build.sh
    sed -i '/if \[ "|$DIFF|" != "||" \]; then/,/fi/{s/^/#/}' build.sh

    # 3. Only disable the actual hg clone commands, preserve if/else structure
    sed -i 's/hg clone \$MOZILLA_REPO/#hg clone \$MOZILLA_REPO # Disabled/' build.sh
    sed -i 's/hg clone \$COMM_REPO/#hg clone \$COMM_REPO # Disabled/' build.sh

    # 4. Comment out the exit statements after failed clones
    sed -i 's/|| exit 1/#|| exit 1 # Disabled/' build.sh

    echo "Verification:"
    echo "Current directory contents:"
    ls -la .
    echo "Looking for remaining hg clone commands:"
    grep -n "hg clone" build.sh || echo "No active hg clone commands found"

    # Set up build environment variables
    export HOME=$TMPDIR
    export MOZBUILD_STATE_PATH=$TMPDIR/.mozbuild
  '';

  buildPhase = ''
    echo "======================================================="
    echo "Starting Betterbird build"
    echo "======================================================="

    # Debug: Check our current directory and contents
    echo "Current working directory: $(pwd)"
    echo "Directory contents:"
    ls -la .

    # The version directories are just major versions (128, 140, etc.)
    MAJOR_VERSION=$(echo "${version}" | cut -d. -f1)
    echo "Using major version: $MAJOR_VERSION"

    # Patch the shebang if needed
    SHEBANG=$(head -1 build.sh)
    echo "Original shebang: $SHEBANG"

    if [[ "$SHEBANG" == "#!/bin/bash" ]]; then
      echo "Patching shebang to use nix bash..."
      sed -i "1s|#!/bin/bash|#!${bash}/bin/bash|" build.sh
      echo "New shebang: $(head -1 build.sh)"
    fi

    # Check the mozilla repo is where we expect it
    if [ -d mozilla-esr128 ]; then
      echo "✅ mozilla-esr128 directory exists"
      echo "Contents preview:"
      ls mozilla-esr128/ | head -5
    else
      echo "❌ mozilla-esr128 directory NOT found!"
      echo "Available directories:"
      ls -la .
      exit 1
    fi

    # Try to run the script with the major version
    echo "Attempting to run build script with version $MAJOR_VERSION..."
    ./build.sh $MAJOR_VERSION || {
      echo "Build script failed. Debugging info:"
      echo "Final directory contents:"
      ls -la .
      echo "Script around line 91:"
      sed -n '85,95p' build.sh
      exit 1
    }
  '';

  installPhase = ''
    mkdir -p $out
    echo "Install phase - to be implemented after build works"
  '';

  meta = with lib; {
    description = "Betterbird is a fine-tuned version of Mozilla Thunderbird";
    homepage = "https://www.betterbird.eu/";
    license = licenses.mpl20;
    maintainers = [ ];
    platforms = platforms.linux;
  };
}

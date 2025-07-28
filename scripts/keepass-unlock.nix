{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.services.keepass-unlock;
  
  # Crypto utilities
  encryptScript = pkgs.writeShellScript "kp-encrypt" ''
    set -euo pipefail
    PASSWORD="$1"
    KEYFILE="$2"
    
    # Derive encryption key from system characteristics + user input
    SYSTEM_ID=$(sha256sum /etc/machine-id | cut -d' ' -f1)
    ENCRYPTION_KEY=$(echo -n "$SYSTEM_ID$(whoami)" | sha256sum | cut -d' ' -f1)
    
    # Encrypt password
    echo -n "$PASSWORD" | ${pkgs.openssl}/bin/openssl enc -aes-256-cbc -base64 -pass "pass:$ENCRYPTION_KEY" > "$KEYFILE"
    echo "Password encrypted and stored in $KEYFILE"
  '';
  
  decryptScript = pkgs.writeShellScript "kp-decrypt" ''
    set -euo pipefail
    KEYFILE="$1"
    
    if [[ ! -f "$KEYFILE" ]]; then
      echo "Encrypted password file not found: $KEYFILE"
      exit 1
    fi
    
    # Same key derivation
    SYSTEM_ID=$(sha256sum /etc/machine-id | cut -d' ' -f1)
    ENCRYPTION_KEY=$(echo -n "$SYSTEM_ID$(whoami)" | sha256sum | cut -d' ' -f1)
    
    # Decrypt password
    ${pkgs.openssl}/bin/openssl enc -aes-256-cbc -d -base64 -pass "pass:$ENCRYPTION_KEY" -in "$KEYFILE"
  '';
  
  unlockScript = pkgs.writeShellScript "kp-unlock" ''
    set -euo pipefail
    
    DB_PATH="${cfg.databasePath}"
    KEYFILE_PATH="${cfg.keyfilePath}"
    ENCRYPTED_PW_PATH="${cfg.encryptedPasswordPath}"
    
    if [[ ! -f "$DB_PATH" ]]; then
      echo "KeePass database not found: $DB_PATH"
      exit 1
    fi
    
    if [[ ! -f "$KEYFILE_PATH" ]]; then
      echo "KeePass keyfile not found: $KEYFILE_PATH"  
      exit 1
    fi
    
    if [[ ! -f "$ENCRYPTED_PW_PATH" ]]; then
      echo "Encrypted password not found: $ENCRYPTED_PW_PATH"
      exit 1
    fi
    
    # Decrypt password
    PASSWORD=$(${decryptScript} "$ENCRYPTED_PW_PATH")
    
    # Test unlock (dry run)
    echo "$PASSWORD" | ${pkgs.keepassxc}/bin/keepassxc-cli db-info "$DB_PATH" --keyfile "$KEYFILE_PATH" > /dev/null
    
    if [[ $? -eq 0 ]]; then
      echo "KeePassXC database successfully unlocked"
      # Re-encrypt password (password rotation)
      echo "$PASSWORD" | ${encryptScript} "$PASSWORD" "$ENCRYPTED_PW_PATH"
    else
      echo "Failed to unlock KeePassXC database"
      exit 1
    fi
  '';
  
  setupScript = pkgs.writeShellScript "kp-setup" ''
    set -euo pipefail
    
    echo "=== KeePassXC Auto-Unlock Setup ==="
    echo "Database path: ${cfg.databasePath}"
    echo "Keyfile path: ${cfg.keyfilePath}"
    echo "Encrypted password will be stored in: ${cfg.encryptedPasswordPath}"
    echo
    
    if [[ ! -f "${cfg.databasePath}" ]]; then
      echo "❌ Database file not found!"
      exit 1
    fi
    
    if [[ ! -f "${cfg.keyfilePath}" ]]; then
      echo "❌ Keyfile not found!"
      exit 1
    fi
    
    # Ensure directory exists
    mkdir -p "$(dirname "${cfg.encryptedPasswordPath}")"
    
    echo -n "Enter KeePassXC database password: "
    read -s PASSWORD
    echo
    
    # Test the password works
    echo "Testing password..."
    echo "$PASSWORD" | ${pkgs.keepassxc}/bin/keepassxc-cli db-info "${cfg.databasePath}" --keyfile "${cfg.keyfilePath}" > /dev/null
    
    if [[ $? -eq 0 ]]; then
      echo "✅ Password verified!"
      ${encryptScript} "$PASSWORD" "${cfg.encryptedPasswordPath}"
      chmod 600 "${cfg.encryptedPasswordPath}"
      echo "✅ Setup complete!"
    else
      echo "❌ Password verification failed!"
      exit 1
    fi
  '';

in {
  options.services.keepass-unlock = {
    enable = mkEnableOption "KeePassXC automatic unlock service";
    
    databasePath = mkOption {
      type = types.str;
      example = "/home/user/.local/share/keepassxc/database.kdbx";
      description = "Path to KeePassXC database file";
    };
    
    keyfilePath = mkOption {
      type = types.str;
      example = "/home/user/.local/share/keepassxc/keyfile.key";
      description = "Path to KeePassXC keyfile";
    };
    
    encryptedPasswordPath = mkOption {
      type = types.str;
      default = "/var/lib/keepass-unlock/encrypted_password";
      description = "Path where encrypted password is stored";
    };
    
    user = mkOption {
      type = types.str;
      example = "username";
      description = "User who owns the KeePassXC database";
    };
    
    unlockOnBoot = mkOption {
      type = types.bool;
      default = true;
      description = "Automatically unlock database on system boot";
    };
  };
  
  config = mkIf cfg.enable {
    # Create unlock service
    systemd.services.keepass-unlock = mkIf cfg.unlockOnBoot {
      description = "KeePassXC Auto Unlock";
      after = [ "graphical-session.target" ];
      wantedBy = [ "graphical-session.target" ];
      
      serviceConfig = {
        Type = "oneshot";
        User = cfg.user;
        ExecStart = unlockScript;
        RemainAfterExit = false;
      };
    };
    
    # Setup script available system-wide
    environment.systemPackages = [
      (pkgs.writeShellScriptBin "keepass-setup" ''
        exec ${setupScript} "$@"
      '')
      (pkgs.writeShellScriptBin "keepass-unlock-manual" ''
        exec ${unlockScript} "$@"
      '')
    ];
    
    # Ensure directory exists with correct permissions
    systemd.tmpfiles.rules = [
      "d ${dirOf cfg.encryptedPasswordPath} 0700 ${cfg.user} ${cfg.user} -"
    ];
  };
}

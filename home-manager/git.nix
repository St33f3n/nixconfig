{
  config,
  pkgs,
  inputs,
  ...
}:
{
  programs.git = {
    enable = true;
    package = pkgs.gitAndTools.gitFull;
    extraConfig = {
      # Credential Helper
      credential.helper = "${pkgs.git.override { withLibsecret = true; }}/bin/git-credential-libsecret";
      
      # Default Branch
      init.defaultBranch = "master";
      
      # Core Settings
      core = {
        editor = "helix";  # Standard-Editor für Commit-Nachrichten
        autocrlf = "input";  # Line-Ending-Behandlung (input für Unix/Linux)
        whitespace = "trailing-space,space-before-tab";  # Whitespace-Warnungen
        pager = "less -FRX";  # Pager-Einstellungen
      };
      
      # Pull/Merge Strategy
      pull = {
        rebase = false;  # Standard: merge statt rebase beim Pull
        ff = "only";  # Nur Fast-Forward-Merges erlauben
      };
      
      # Push Settings
      push = {
        default = "simple";  # Nur aktuellen Branch pushen
        followTags = false;  # Tags nicht automatisch mitpushen
        autoSetupRemote = true;  # Automatisch Remote-Branch beim ersten Push erstellen
      };
      
      # Merge Settings
      merge = {
        conflictStyle = "merge";  # Konflikt-Darstellung (merge/diff3/zdiff3)
        ff = true;  # Fast-Forward-Merges erlauben
      };
      
      # Fetch Settings
      fetch = {
        prune = false;  # Gelöschte Remote-Branches nicht automatisch lokal entfernen
        pruneTags = false;  # Gelöschte Remote-Tags nicht automatisch lokal entfernen
      };
      
      # Diff Settings
      diff = {
        algorithm = "myers";  # Diff-Algorithmus (myers/minimal/patience/histogram)
        renames = true;  # Umbenennungen erkennen
        colorMoved = "default";  # Verschobenen Code farblich markieren
      };
      
      # Color Settings
      color = {
        ui = "auto";  # Automatische Farbausgabe
        branch = "auto";
        diff = "auto";
        status = "auto";
      };
      
      # Branch Settings
      branch = {
        autoSetupMerge = "true";  # Automatisch Tracking-Branch einrichten
        autoSetupRebase = "never";  # Kein automatisches Rebase
      };
      
      # Commit Settings
      commit = {
        verbose = false;  # Diff in Commit-Message-Editor anzeigen
        gpgSign = false;  # GPG-Signierung von Commits
      };
      
      # Tag Settings
      tag = {
        gpgSign = false;  # GPG-Signierung von Tags
        sort = "-version:refname";  # Tag-Sortierung
      };
      
      # Rebase Settings
      rebase = {
        autoSquash = false;  # Automatisches Squashing bei Rebase
        autoStash = false;  # Automatisches Stashing vor Rebase
      };
      
      # Status Settings
      status = {
        showUntrackedFiles = "all";  # Alle untracked Files anzeigen
        submoduleSummary = false;  # Submodule-Zusammenfassung
      };
      
      # Log Settings
      log = {
        abbrevCommit = false;  # Verkürzte Commit-Hashes
        decorate = "auto";  # Branch/Tag-Namen im Log anzeigen
      };
      
      # Help Settings
      help = {
        autoCorrect = 0;  # Keine automatische Korrektur (0 = aus, >0 = Verzögerung in 0.1s)
      };
    };
    userName = "Stefan Simmeth";
    userEmail = "stefan.simmeth@protonmail.com";
  };

}

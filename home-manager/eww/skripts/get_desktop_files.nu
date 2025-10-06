#!/usr/bin/env nu

# Sammelt alle Desktop-Applikationen und gibt sie als JSON aus
def main [] {
    # Alle .desktop Dateien finden
    let desktop_files = (
        eza /run/current-system/sw/share/applications 
        | rg \.desktop 
        | lines 
        | split column "->"
        | rename filename realpath
        | get realpath
        | each { |path| $path | str trim }
    )
    
    # Jede Desktop-Datei parsen
    let apps = (
        $desktop_files 
        | each { |file|
            parse_desktop_file $file
        }
        | compact  # Filtert null-Werte automatisch
        | where terminal == false  # Nur GUI-Applikationen
    )
    
    # Als JSON ausgeben
    $apps | to json
}

# Parst eine .desktop Datei und extrahiert relevante Informationen
def parse_desktop_file [file: string] {
    try {
        let content = (open $file)
        
        # Extrahiere Felder direkt mit Nushell-String-Funktionen
        let name = (
            $content 
            | lines
            | find --regex '^Name='
            | first
            | split row '='
            | get 1
            | str trim
        )
        
        let exec = (
            $content 
            | lines
            | find --regex '^Exec='
            | first
            | split row '='
            | get 1
            | str trim
            | str replace --all '%[UuFf]' ''
            | str replace --all '%[cCkK]' ''
            | str trim
        )
        
        let icon = (
            $content 
            | lines
            | find --regex '^Icon='
            | first
            | split row '='
            | get 1
            | str trim
        )
        
        let terminal = (
            $content 
            | lines
            | find --regex '^Terminal='
            | first
            | split row '='
            | get 1
            | str trim
            | str downcase
        )
        
        let comment = (
            $content 
            | lines
            | find --regex '^Comment='
            | first
            | split row '='
            | get 1
            | str trim
        )
        
        # Gebe strukturiertes Objekt zurück
        {
            name: $name,
            exec: $exec,
            icon: $icon,
            terminal: ($terminal == "true"),
            comment: $comment,
            desktop_file: $file
        }
    } catch {
        null  # Bei Fehlern null zurückgeben
    }
}


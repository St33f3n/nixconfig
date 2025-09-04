import QtQuick 
import QtQuick.Layouts
import QtQuick.Shapes 
import Quickshell.Hyprland

Rectangle {
    id: workspaceIndicator
    
    // === HAUPTEIGENSCHAFTEN ===
    implicitHeight: 24
    implicitWidth: workspaceLayout.implicitWidth
    color: "transparent"
    property int fontSize: 12
    
    // === KONFIGURIERBARE EIGENSCHAFTEN ===
    // Theme-Farben
    property color accentColor: "#4c9aff"
    property color accentHoverColor: "#6badff"
    property color normalColor: "#404040"
    property color normalHoverColor: "#505050"
    property color strokeColor: "#202020"
    property color strokeHoverColor: "#303030"
    
    // Hexagon-Dimensionen
    property real hexagonWidth: 29
    property real hexagonHeight: 25
    
    // Text-Farben
    property color focusedTextColor: "white"
    property color unfocusedTextColor: "#888888"
    property color hoverTextColor: "#dddddd"
    
    // === LAYOUT ===
    RowLayout {
        id: workspaceLayout
        anchors.fill: parent
        spacing: 3
        
        Repeater {
            model: Hyprland.workspaces
            
            delegate: Item {
                id: workspaceDelegate
                required property HyprlandWorkspace modelData
                
                // === DIMENSIONEN ===
                width: workspaceIndicator.hexagonWidth
                height: workspaceIndicator.hexagonHeight
                
                // === ZUSTANDSVARIABLEN ===
                property bool isHovered: mouseArea.containsMouse
                property bool isFocused: modelData.focused
                property bool isPressed: mouseArea.pressed
                
                // === FARB-LOGIK ===
                property color currentFillColor: {
                    if (isFocused) {
                        return isHovered ? workspaceIndicator.accentHoverColor 
                                        : workspaceIndicator.accentColor
                    } else {
                        return isHovered ? workspaceIndicator.normalHoverColor 
                                        : workspaceIndicator.normalColor
                    }
                }
                
                property color currentStrokeColor: {
                    return isHovered ? workspaceIndicator.strokeHoverColor 
                                     : workspaceIndicator.strokeColor
                }
                
                property color currentTextColor: {
                    if (isFocused) {
                        return workspaceIndicator.focusedTextColor
                    } else {
                        return isHovered ? workspaceIndicator.hoverTextColor 
                                        : workspaceIndicator.unfocusedTextColor
                    }
                }
                
                // === HEXAGON SHAPE ===
                Shape {
                    id: hexagonShape
                    anchors.fill: parent
                    
                    // Für bessere Performance
                    layer.enabled: true
                    layer.samples: 4
                    
                    ShapePath {
                        id: hexagonPath
                        strokeWidth: 1
                        strokeColor: workspaceDelegate.currentStrokeColor
                        fillColor: workspaceDelegate.currentFillColor
                        
                        // Hexagon-Geometrie (Spitze nach oben)
                        startX: hexagonShape.width * 0.5
                        startY: 0
                        
                        pathElements: [
                            // Rechts oben
                            PathLine { 
                                x: hexagonShape.width * 0.88
                                y: hexagonShape.height * 0.25 
                            },
                            // Rechts unten
                            PathLine { 
                                x: hexagonShape.width * 0.88
                                y: hexagonShape.height * 0.75 
                            },
                            // Unten
                            PathLine { 
                                x: hexagonShape.width * 0.5
                                y: hexagonShape.height 
                            },
                            // Links unten
                            PathLine { 
                                x: hexagonShape.width * 0.12
                                y: hexagonShape.height * 0.75 
                            },
                            // Links oben
                            PathLine { 
                                x: hexagonShape.width * 0.12
                                y: hexagonShape.height * 0.25 
                            },
                            // Zurück zum Start (oben)
                            PathLine { 
                                x: hexagonShape.width * 0.5
                                y: 0 
                            }
                        ]
                        
                        // === ANIMATIONEN ===
                        Behavior on fillColor {
                            ColorAnimation { 
                                duration: 200
                                easing.type: Easing.OutCubic
                            }
                        }
                        
                        Behavior on strokeColor {
                            ColorAnimation { 
                                duration: 200
                                easing.type: Easing.OutCubic
                            }
                        }
                    }
                }
                
                // === WORKSPACE NUMMER ===
                Text {
                    id: workspaceLabel
                    anchors.centerIn: hexagonShape
                    text: Number(modelData.id) === 10 ? "0" : String(modelData.id)                    
                    font.pointSize: workspaceIndicator.fontSize 
                    font.bold: true
                    color: workspaceDelegate.currentTextColor
                    
                    // Textanimation
                    Behavior on color {
                        ColorAnimation {
                            duration: 150
                            easing.type: Easing.OutCubic
                        }
                    }
                }
                
                // === INTERAKTION ===
                MouseArea {
                    id: mouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    
                    onClicked: {
                        // Workspace wechseln
                        Hyprland.dispatch("workspace " + modelData.id)
                        Hyprland.refreshWorkspaces()
                    }
                }
                
                // === HOVER-EFFEKT: SKALIERUNG ===
                transform: Scale {
                    origin.x: width / 2
                    origin.y: height / 2
                    xScale: workspaceDelegate.isHovered ? 1.1 : 1.0
                    yScale: workspaceDelegate.isHovered ? 1.1 : 1.0
                    
                    Behavior on xScale {
                        NumberAnimation { 
                            duration: 150
                            easing.type: Easing.OutCubic
                        }
                    }
                    
                    Behavior on yScale {
                        NumberAnimation { 
                            duration: 150
                            easing.type: Easing.OutCubic
                        }
                    }
                }
                
                // === OPTIONAL: SCHATTEN-EFFEKT ===
                opacity: isPressed ? 0.8 : 1.0
                Behavior on opacity {
                    NumberAnimation { 
                        duration: 100 
                    }
                }
            }
        }
    }
}

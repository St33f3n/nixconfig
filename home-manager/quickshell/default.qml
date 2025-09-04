// Bar.qml
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland  // Hyprland Import hinzugefügt
import QtQuick
import QtQuick.Layouts
import Quickshell.Widgets

Scope {
    id: root
    
    Theme {
        id: theme
    }
    
    Variants {
        model: Quickshell.screens
        PanelWindow {
            id: bar
            required property var modelData
            property int bar_height: 30
            property int side_margin: 2
            property int internal_margin: 5
            
            screen: modelData
            anchors {
                left: true
                right: true
                top: true
            }
            implicitHeight: bar_height + side_margin*2 + internal_margin  
            surfaceFormat.opaque: false
            color: "transparent"
            GridLayout{
                anchors.fill: parent
                columns: 3
                columnSpacing: 10
                Rectangle {
                    id: bar_left
                    
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: "transparent"
                    implicitHeight: parent.implicitHeight
                    

                    WrapperRectangle {
                        id: wrapper
                        radius: 8
                        margin: bar.internal_margin
                        anchors.left: parent.left
                        anchors.top: parent.top
                        anchors.topMargin: bar.side_margin
                        anchors.leftMargin: bar.side_margin
                        implicitHeight: parent.height - bar.side_margin
                        border.color: theme.border
                        border.width: theme.border_size
                        width: Math.max(workspacesnsystem.implicitWidth + 20, 50)
                        color: theme.bar_background

                        RowLayout {
                            id: workspacesnsystem
                            anchors.fill: parent
                            anchors.margins: bar.internal_margin
                            spacing: 2
                            
                            IconButton {
                                text: "test"
                                iconSource: "nix.png"
                                implicitWidth: 25
                                iconScale: 2
                                implicitHeight: implicitWidth
                                onClicked: console.log("test successful")
                            }
                            Workspaces {
                                id: workspaces
                                opacity: 0.8
                                focusedTextColor: theme.fontColor
                                hoverTextColor: theme.accentHoverColor
                                unfocusedTextColor: theme.fontDimmed
                                accentColor: theme.accentColor
                                accentHoverColor: theme.accentHoverColor
                            }

                            IconButton {
                                text: "test"
                                iconSource: "nix.png"
                                implicitWidth: 25
                                iconScale: 2
                                implicitHeight: implicitWidth
                                onClicked: console.log("test successful")
                            }
                        }
                    }
                }
             // ========== MIDDLE ==========
                Rectangle {
                    id: bar_mid
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: "transparent"
                    implicitHeight: parent.implicitHeight

                    WrapperRectangle {
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        anchors.topMargin: bar.side_margin
                        height: parent.height - bar.side_margin
                        radius: 7
                        margin: bar.internal_margin
                        border.color: theme.background
                        border.width: theme.border_size
                        color: theme.bar_background

                        Text {
                            text: root.time_iso
                            font.pixelSize: theme.fontSize+3
                            font.bold: true
                            color: theme.fontColor
                            anchors.centerIn: parent
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                    }
                }               
                
                Rectangle {
                    id: bar_right
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: "transparent"

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 5

                        Item {
                            Layout.fillWidth: true  // Spacer
                        }

                        Text {
                            text: "placeholder"
                            Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                        }
                    }
                }
            }
        }

    }
    
    // Zeit-Properties...
    readonly property string time: {
        Qt.formatDateTime(clock.date, "ddd d MMM — hh:mm:ss")
    }
    readonly property string time_iso: {
        Qt.formatDateTime(clock.date, "yyyy-MM-dd — hh:mm:ss")
    }
    
    SystemClock {
        id: clock
        precision: SystemClock.Seconds
    }
}


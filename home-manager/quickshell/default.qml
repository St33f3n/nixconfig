// ~/.config/quickshell/shell.qml
import Quickshell
import QtQuick

PanelWindow {
    anchors {
        top: true
        left: true 
        right: true
    }
    implicitHeight: 32
    
    Rectangle {
        anchors.fill: parent
        color: "#2a2a2a"
        
        Text {
            anchors.centerIn: parent
            text: "Meine erste quickshell Bar"
            color: "white"
            font.pointSize: 12
        }
    }


    
}

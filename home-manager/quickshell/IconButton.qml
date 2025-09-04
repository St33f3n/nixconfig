import QtQuick.Controls
import QtQuick

Button {
    id: root
    flat: true
    hoverEnabled: true
    clip: false  // Allows ripple to extend beyond button bounds
    
    // Properties
    property url iconSource: ""
    property real iconScale: 2.0
    property real onHoverScale: 1.3
    property alias iconOpacity: icon.opacity
    
    // Click handler - writes success message to console and triggers ripple
    onClicked: {
        console.log("IconButton clicked successfully!")
        rippleAnimation.start()
    }
    
    // Enhanced visual feedback on press
    onPressed: scale = onHoverScale * 0.95
    onReleased: scale = hovered ? onHoverScale : 1.0
    
    // Transparent background
    background: Rectangle {
        color: "transparent"
    }
    
    // Icon content
    contentItem: Image {
        id: icon
        source: root.iconSource
        smooth: true
        mipmap: true
        fillMode: Image.PreserveAspectFit
        
        // Optimized sizing
        width: Math.min(parent.width, parent.height) * root.iconScale
        height: width
        
        // High-resolution source for crisp rendering
        sourceSize.width: width * 2
        sourceSize.height: height * 2
        
        // Center the icon
        anchors.centerIn: parent
    }
    
    // Hover states with smooth transitions
    states: [
        State {
            name: "hovered"
            when: root.hovered && !root.pressed
            PropertyChanges {
                target: root
                scale: root.onHoverScale
            }
        },
        State {
            name: "normal"
            when: !root.hovered && !root.pressed
            PropertyChanges {
                target: root
                scale: 1.0
            }
        }
    ]
    
    // Smooth transitions
    transitions: [
        Transition {
            from: "normal"
            to: "hovered"
            reversible: true
            NumberAnimation {
                properties: "scale"
                duration: 200
                easing.type: Easing.OutQuad
            }
        }
    ]
    
    // Enhanced ripple effect that can extend beyond button bounds
    Rectangle {
        id: ripple
        anchors.centerIn: parent
        width: 0
        height: width
        radius: width / 2
        color: Qt.rgba(0.8, 0.8, 1.0, 0.4)  // Subtle blue ripple
        visible: false
        z: -1  // Behind the icon but visible beyond button bounds
        
        SequentialAnimation {
            id: rippleAnimation
            PropertyAnimation {
                target: ripple
                property: "visible"
                to: true
                duration: 1
            }
            ParallelAnimation {
                PropertyAnimation {
                    target: ripple
                    property: "width"
                    to: Math.max(root.width, root.height) * 3  // Larger ripple extends beyond button
                    duration: 400
                    easing.type: Easing.OutQuad
                }
                PropertyAnimation {
                    target: ripple
                    property: "opacity"
                    from: 0.6
                    to: 0
                    duration: 400
                }
            }
            PropertyAnimation {
                target: ripple
                property: "visible"
                to: false
                duration: 1
            }
            PropertyAnimation {
                target: ripple
                property: "width"
                to: 0
                duration: 1
            }
            PropertyAnimation {
                target: ripple
                property: "opacity"
                to: 0.6
                duration: 1
            }
        }
    }
}

import QtQuick
import QtQuick.Controls
import "../theme"

/**
 * NeonButton - Animated button with gradient and glow effects
 */
Button {
    id: root
    
    property color accentColor: Theme.accentPrimary
    property bool loading: false
    
    implicitWidth: Math.max(120, contentItem.implicitWidth + 40)
    implicitHeight: 44
    
    contentItem: Text {
        text: root.text
        font.pixelSize: Theme.fontSizeMedium
        font.bold: true
        color: Theme.textPrimary
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        opacity: root.loading ? 0 : 1
    }
    
    background: Rectangle {
        id: bg
        radius: Theme.radiusM
        
        gradient: Gradient {
            orientation: Gradient.Horizontal
            GradientStop { 
                position: 0.0
                color: root.pressed ? Qt.darker(root.accentColor, 1.2) : root.accentColor
            }
            GradientStop { 
                position: 1.0
                color: root.pressed ? Qt.darker(Theme.accentTertiary, 1.2) : Theme.accentTertiary
            }
        }
        
        // Shimmer effect on hover
        Rectangle {
            id: shimmer
            width: parent.width * 0.4
            height: parent.height
            radius: parent.radius
            x: -width
            
            gradient: Gradient {
                orientation: Gradient.Horizontal
                GradientStop { position: 0.0; color: "transparent" }
                GradientStop { position: 0.5; color: Qt.rgba(1, 1, 1, 0.3) }
                GradientStop { position: 1.0; color: "transparent" }
            }
            
            visible: root.hovered && !root.loading
        }
        
        // Glow effect (simple fallback)
        Rectangle {
            anchors.fill: parent
            anchors.margins: -2
            z: -1
            radius: parent.radius + 2
            color: "transparent"
            border.color: root.hovered || root.pressed ? Qt.rgba(root.accentColor.r, root.accentColor.g, root.accentColor.b, 0.6) : "transparent"
            border.width: 3
            
            Behavior on border.color {
                ColorAnimation { duration: Theme.animFast }
            }
        }
    }
    
    // Loading spinner
    Item {
        anchors.centerIn: parent
        visible: root.loading
        width: 24
        height: 24
        
        Rectangle {
            id: spinner
            anchors.fill: parent
            radius: width / 2
            color: "transparent"
            border.color: Theme.textPrimary
            border.width: 3
            
            Rectangle {
                width: parent.width * 0.3
                height: width
                radius: width / 2
                color: Theme.textPrimary
                anchors.top: parent.top
                anchors.horizontalCenter: parent.horizontalCenter
            }
            
            RotationAnimation on rotation {
                from: 0
                to: 360
                duration: 1000
                loops: Animation.Infinite
                running: root.loading
            }
        }
    }
    
    // Scale animation on press
    scale: pressed ? 0.95 : 1.0
    
    Behavior on scale {
        NumberAnimation {
            duration: Theme.animFast
            easing.type: Easing.OutCubic
        }
    }
    
    // Shimmer animation on hover
    SequentialAnimation {
        id: shimmerAnim
        running: root.hovered && !root.loading
        loops: Animation.Infinite
        
        PauseAnimation { duration: 500 }
        
        NumberAnimation {
            target: shimmer
            property: "x"
            from: -shimmer.width
            to: root.width
            duration: 600
            easing.type: Easing.InOutQuad
        }
        
        PauseAnimation { duration: 1000 }
    }
    
    onHoveredChanged: {
        if (!hovered) {
            shimmer.x = -shimmer.width
        }
    }
}

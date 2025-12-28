import QtQuick
import "../theme"

/**
 * GlassCard - Glassmorphism card component with blur effect
 */
Rectangle {
    id: root
    
    property bool hoverable: true
    property bool hovered: mouseArea.containsMouse
    
    color: Qt.rgba(
        Theme.bgCard.r,
        Theme.bgCard.g,
        Theme.bgCard.b,
        Theme.cardOpacity
    )
    radius: Theme.radiusL
    border.color: hovered ? Theme.borderAccent : Theme.borderLight
    border.width: 1
    
    // Subtle lift on hover
    transform: Translate {
        y: root.hovered && root.hoverable ? -4 : 0
        
        Behavior on y {
            NumberAnimation {
                duration: Theme.animNormal
                easing.type: Easing.OutCubic
            }
        }
    }
    
    // Glow effect on hover (simple fallback)
    Rectangle {
        anchors.fill: parent
        anchors.margins: -2
        z: -1
        radius: parent.radius + 2
        color: "transparent"
        border.color: root.hovered && root.hoverable ? Theme.glowCyan : "transparent"
        border.width: 2
        opacity: 0.6
        
        Behavior on border.color {
            ColorAnimation { duration: Theme.animNormal }
        }
    }
    
    Behavior on border.color {
        ColorAnimation { duration: Theme.animNormal }
    }
    
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: root.hoverable
        cursorShape: root.hoverable ? Qt.PointingHandCursor : Qt.ArrowCursor
        propagateComposedEvents: true
        
        onPressed: function(mouse) { mouse.accepted = false }
        onReleased: function(mouse) { mouse.accepted = false }
        onClicked: function(mouse) { mouse.accepted = false }
    }
}

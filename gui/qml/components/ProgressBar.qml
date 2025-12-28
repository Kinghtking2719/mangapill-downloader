import QtQuick
import QtQuick.Controls
import "../theme"

/**
 * ProgressBar - Animated gradient progress bar
 */
Item {
    id: root
    
    property real value: 0.0  // 0.0 to 1.0
    property string label: ""
    property bool showPercentage: true
    property bool animated: true
    
    implicitWidth: 300
    implicitHeight: 32
    
    // Track
    Rectangle {
        id: track
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        height: 8
        radius: 4
        color: Theme.bgCard
        border.color: Theme.borderLight
        border.width: 1
        
        // Filled portion with gradient
        Rectangle {
            id: fill
            width: parent.width * root.value
            height: parent.height
            radius: parent.radius
            clip: true
            
            gradient: Gradient {
                orientation: Gradient.Horizontal
                GradientStop { position: 0.0; color: Theme.accentPrimary }
                GradientStop { position: 0.5; color: Theme.accentTertiary }
                GradientStop { position: 1.0; color: Theme.accentSecondary }
            }
            
            Behavior on width {
                enabled: root.animated
                NumberAnimation {
                    duration: Theme.animNormal
                    easing.type: Easing.OutCubic
                }
            }
            
            // Animated shimmer
            Rectangle {
                id: shimmer
                width: parent.width * 0.3
                height: parent.height
                x: -width
                
                gradient: Gradient {
                    orientation: Gradient.Horizontal
                    GradientStop { position: 0.0; color: "transparent" }
                    GradientStop { position: 0.5; color: Qt.rgba(1, 1, 1, 0.4) }
                    GradientStop { position: 1.0; color: "transparent" }
                }
                
                SequentialAnimation on x {
                    running: root.value > 0 && root.value < 1
                    loops: Animation.Infinite
                    
                    NumberAnimation {
                        from: -shimmer.width
                        to: fill.width
                        duration: 1500
                        easing.type: Easing.InOutQuad
                    }
                    
                    PauseAnimation { duration: 500 }
                }
            }
        }
        
        // Glow effect
        Rectangle {
            anchors.fill: fill
            radius: fill.radius
            color: "transparent"
            border.color: Qt.rgba(
                Theme.accentPrimary.r,
                Theme.accentPrimary.g,
                Theme.accentPrimary.b,
                0.4
            )
            border.width: 2
            visible: root.value > 0
        }
    }
    
    // Label
    Text {
        anchors.left: parent.left
        anchors.bottom: track.top
        anchors.bottomMargin: 4
        text: root.label
        font.pixelSize: Theme.fontSizeSmall
        color: Theme.textSecondary
        visible: root.label !== ""
    }
    
    // Percentage
    Text {
        anchors.right: parent.right
        anchors.bottom: track.top
        anchors.bottomMargin: 4
        text: Math.round(root.value * 100) + "%"
        font.pixelSize: Theme.fontSizeSmall
        font.bold: true
        color: Theme.accentPrimary
        visible: root.showPercentage
        
        // Animate the number
        Behavior on text {
            enabled: false
        }
    }
}

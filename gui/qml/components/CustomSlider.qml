import QtQuick
import QtQuick.Controls
import "../theme"

/**
 * CustomSlider - Styled slider with value tooltip
 */
Slider {
    id: root
    
    property color accentColor: Theme.accentPrimary
    property string suffix: ""
    property int decimals: 0
    
    implicitWidth: 200
    implicitHeight: 32
    
    background: Rectangle {
        x: root.leftPadding
        y: root.topPadding + root.availableHeight / 2 - height / 2
        width: root.availableWidth
        height: 6
        radius: 3
        color: Theme.bgCard
        border.color: Theme.borderLight
        border.width: 1
        
        // Filled portion
        Rectangle {
            width: root.visualPosition * parent.width
            height: parent.height
            radius: parent.radius
            
            gradient: Gradient {
                orientation: Gradient.Horizontal
                GradientStop { position: 0.0; color: root.accentColor }
                GradientStop { position: 1.0; color: Theme.accentTertiary }
            }
        }
    }
    
    handle: Rectangle {
        x: root.leftPadding + root.visualPosition * (root.availableWidth - width)
        y: root.topPadding + root.availableHeight / 2 - height / 2
        width: 20
        height: 20
        radius: 10
        color: Theme.textPrimary
        border.color: root.pressed ? root.accentColor : Theme.borderLight
        border.width: 2
        
        // Value tooltip
        Rectangle {
            id: tooltip
            anchors.bottom: parent.top
            anchors.bottomMargin: 8
            anchors.horizontalCenter: parent.horizontalCenter
            width: tooltipText.width + 16
            height: tooltipText.height + 8
            radius: Theme.radiusS
            color: Theme.bgCard
            border.color: Theme.borderLight
            border.width: 1
            visible: root.pressed
            opacity: root.pressed ? 1 : 0
            
            Behavior on opacity {
                NumberAnimation { duration: Theme.animFast }
            }
            
            Text {
                id: tooltipText
                anchors.centerIn: parent
                text: root.decimals > 0 
                    ? root.value.toFixed(root.decimals) + root.suffix
                    : Math.round(root.value) + root.suffix
                font.pixelSize: Theme.fontSizeSmall
                font.bold: true
                color: Theme.textPrimary
            }
        }
        
        Behavior on border.color {
            ColorAnimation { duration: Theme.animFast }
        }
        
        // Scale on press
        scale: root.pressed ? 1.2 : (root.hovered ? 1.1 : 1.0)
        
        Behavior on scale {
            NumberAnimation {
                duration: Theme.animFast
                easing.type: Easing.OutCubic
            }
        }
        
        // Glow effect
        Rectangle {
            anchors.fill: parent
            anchors.margins: -4
            radius: parent.radius + 4
            color: "transparent"
            border.color: Qt.rgba(
                root.accentColor.r,
                root.accentColor.g,
                root.accentColor.b,
                root.pressed ? 0.5 : 0
            )
            border.width: 4
            
            Behavior on border.color {
                ColorAnimation { duration: Theme.animFast }
            }
        }
    }
}

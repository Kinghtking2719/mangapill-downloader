import QtQuick
import QtQuick.Controls
import "../theme"

/**
 * ToggleSwitch - iOS-style animated toggle switch with clear ON/OFF states
 */
Switch {
    id: root
    
    property color activeColor: Theme.accentPrimary
    property color inactiveColor: "#2A2A3A"  // Dark background when off
    
    implicitWidth: 60
    implicitHeight: 32
    
    indicator: Rectangle {
        id: track
        width: root.implicitWidth
        height: root.implicitHeight
        radius: height / 2
        color: root.checked ? root.activeColor : root.inactiveColor
        border.color: root.checked ? Qt.lighter(root.activeColor, 1.3) : "#5A5A6A"
        border.width: 2
        
        Behavior on color {
            ColorAnimation { duration: Theme.animNormal }
        }
        
        Behavior on border.color {
            ColorAnimation { duration: Theme.animNormal }
        }
        
        // ON/OFF indicator text
        Text {
            anchors.left: root.checked ? parent.left : undefined
            anchors.right: root.checked ? undefined : parent.right
            anchors.leftMargin: 8
            anchors.rightMargin: 8
            anchors.verticalCenter: parent.verticalCenter
            text: root.checked ? "ON" : "OFF"
            font.pixelSize: 9
            font.bold: true
            color: root.checked ? Theme.bgPrimary : "#888899"
            opacity: 0.9
            
            Behavior on opacity {
                NumberAnimation { duration: Theme.animFast }
            }
        }
        
        // Knob
        Rectangle {
            id: knob
            width: 24
            height: 24
            radius: height / 2
            anchors.verticalCenter: parent.verticalCenter
            x: root.checked ? parent.width - width - 4 : 4
            
            // Knob color changes based on state
            color: root.checked ? "#FFFFFF" : "#AAAAAA"
            
            // Checkmark when ON
            Text {
                anchors.centerIn: parent
                text: root.checked ? "✓" : ""
                font.pixelSize: 12
                font.bold: true
                color: Theme.accentPrimary
                visible: root.checked
            }
            
            Behavior on x {
                NumberAnimation {
                    duration: Theme.animNormal
                    easing.type: Easing.OutBack
                    easing.overshoot: 1.2
                }
            }
            
            Behavior on color {
                ColorAnimation { duration: Theme.animNormal }
            }
            
            // Scale bounce on change
            scale: root.pressed ? 0.9 : 1.0
            
            Behavior on scale {
                NumberAnimation {
                    duration: Theme.animFast
                    easing.type: Easing.OutCubic
                }
            }
        }
        
        // Glow effect when active
        Rectangle {
            anchors.fill: parent
            anchors.margins: -3
            z: -1
            radius: parent.radius + 3
            color: "transparent"
            border.color: root.checked ? Qt.rgba(
                root.activeColor.r,
                root.activeColor.g,
                root.activeColor.b,
                0.5
            ) : "transparent"
            border.width: 3
            
            Behavior on border.color {
                ColorAnimation { duration: Theme.animNormal }
            }
        }
    }
    
    background: Item {}
}

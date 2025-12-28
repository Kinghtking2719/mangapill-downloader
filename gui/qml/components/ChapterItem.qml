import QtQuick
import QtQuick.Controls
import "../theme"

/**
 * ChapterItem - Selectable chapter checkbox with animations
 */
Item {
    id: root
    
    property string title: "Chapter 1"
    property bool selected: false
    property int index: 0
    
    signal toggled(bool checked)
    
    implicitWidth: 160  // Minimum width, can grow with Layout.fillWidth
    implicitHeight: 44
    
    Rectangle {
        id: bg
        anchors.fill: parent
        radius: Theme.radiusS
        color: root.selected ? Qt.rgba(
            Theme.accentPrimary.r,
            Theme.accentPrimary.g,
            Theme.accentPrimary.b,
            0.15
        ) : "transparent"
        border.color: root.selected ? Theme.accentPrimary : Theme.borderLight
        border.width: 1
        
        Behavior on color {
            ColorAnimation { duration: Theme.animFast }
        }
        
        Behavior on border.color {
            ColorAnimation { duration: Theme.animFast }
        }
    }
    
    Row {
        anchors.fill: parent
        anchors.margins: Theme.spacingS
        spacing: Theme.spacingS
        
        // Checkbox
        Rectangle {
            id: checkbox
            width: 24
            height: 24
            radius: 6
            anchors.verticalCenter: parent.verticalCenter
            color: root.selected ? Theme.accentPrimary : "transparent"
            border.color: root.selected ? Theme.accentPrimary : Theme.textMuted
            border.width: 2
            
            Behavior on color {
                ColorAnimation { duration: Theme.animFast }
            }
            
            Behavior on border.color {
                ColorAnimation { duration: Theme.animFast }
            }
            
            // Checkmark
            Text {
                anchors.centerIn: parent
                text: "✓"
                font.pixelSize: 14
                font.bold: true
                color: Theme.bgPrimary
                opacity: root.selected ? 1 : 0
                scale: root.selected ? 1 : 0.5
                
                Behavior on opacity {
                    NumberAnimation { duration: Theme.animFast }
                }
                
                Behavior on scale {
                    NumberAnimation {
                        duration: Theme.animNormal
                        easing.type: Easing.OutBack
                    }
                }
            }
        }
        
        // Title
        Text {
            text: root.title
            font.pixelSize: Theme.fontSizeMedium
            color: root.selected ? Theme.textPrimary : Theme.textSecondary
            anchors.verticalCenter: parent.verticalCenter
            elide: Text.ElideRight
            width: parent.width - 40
            
            Behavior on color {
                ColorAnimation { duration: Theme.animFast }
            }
        }
    }
    
    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        
        onClicked: {
            root.selected = !root.selected
            root.toggled(root.selected)
        }
    }
    
    // Ripple effect on click
    Rectangle {
        id: ripple
        anchors.centerIn: parent
        width: 0
        height: 0
        radius: width / 2
        color: Qt.rgba(Theme.accentPrimary.r, Theme.accentPrimary.g, Theme.accentPrimary.b, 0.3)
        opacity: 0
        
        ParallelAnimation {
            id: rippleAnim
            
            NumberAnimation {
                target: ripple
                property: "width"
                from: 0
                to: root.width * 1.5
                duration: 400
            }
            
            NumberAnimation {
                target: ripple
                property: "height"
                from: 0
                to: root.width * 1.5
                duration: 400
            }
            
            NumberAnimation {
                target: ripple
                property: "opacity"
                from: 0.5
                to: 0
                duration: 400
            }
        }
    }
    
    Connections {
        target: root
        
        function onSelectedChanged() {
            rippleAnim.start()
        }
    }
}

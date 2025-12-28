import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../theme"
import "../components"

/**
 * HomeScreen - Main entry screen with URL input
 */
Item {
    id: root
    
    signal mangaLoaded(var manga)
    signal openSettings()
    
    property bool isLoading: false
    
    ColumnLayout {
        anchors.fill: parent
        spacing: Theme.spacingXL
        
        // ==================== Logo Section ====================
        
        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: 120
            
            // Animated logo text
            Text {
                id: logoText
                anchors.centerIn: parent
                text: "🎴 MANGAPILL"
                font.pixelSize: Theme.fontSizeHero
                font.bold: true
                color: Theme.accentPrimary
                
                // Glow effect via layered text
                Text {
                    anchors.fill: parent
                    text: parent.text
                    font: parent.font
                    color: Theme.accentPrimary
                    opacity: 0.5
                    // Blur approximation with offset copies
                    transform: Translate { x: 2; y: 2 }
                }
                
                // Pulse animation
                SequentialAnimation on opacity {
                    loops: Animation.Infinite
                    NumberAnimation { to: 0.7; duration: 2000; easing.type: Easing.InOutSine }
                    NumberAnimation { to: 1.0; duration: 2000; easing.type: Easing.InOutSine }
                }
            }
            
            Text {
                anchors.top: logoText.bottom
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.topMargin: Theme.spacingS
                text: "DOWNLOADER"
                font.pixelSize: Theme.fontSizeXLarge
                font.letterSpacing: 8
                color: Theme.textSecondary
            }
        }
        
        // ==================== URL Input Section ====================
        
        GlassCard {
            Layout.fillWidth: true
            Layout.preferredHeight: 180
            Layout.leftMargin: Theme.spacingXXL
            Layout.rightMargin: Theme.spacingXXL
            hoverable: false
            
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: Theme.spacingL
                spacing: Theme.spacingM
                
                Text {
                    text: "🔗 Enter Manga URL"
                    font.pixelSize: Theme.fontSizeXLarge
                    font.bold: true
                    color: Theme.textPrimary
                }
                
                // URL Input
                Rectangle {
                    Layout.fillWidth: true
                    height: 50
                    radius: Theme.radiusM
                    color: Theme.bgPrimary
                    border.color: urlInput.activeFocus ? Theme.accentPrimary : Theme.borderLight
                    border.width: urlInput.activeFocus ? 2 : 1
                    
                    Behavior on border.color {
                        ColorAnimation { duration: Theme.animFast }
                    }
                    
                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: Theme.spacingS
                        spacing: Theme.spacingS
                        
                        TextField {
                            id: urlInput
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            placeholderText: "https://mangapill.com/manga/..."
                            placeholderTextColor: Theme.textMuted
                            color: Theme.textPrimary
                            font.pixelSize: Theme.fontSizeMedium
                            background: Item {}
                            selectByMouse: true
                            
                            onAccepted: fetchButton.clicked()
                        }
                        
                        // Search icon
                        Text {
                            text: "🔍"
                            font.pixelSize: 20
                            opacity: 0.6
                        }
                    }
                }
                
                // Fetch Button
                NeonButton {
                    id: fetchButton
                    Layout.alignment: Qt.AlignHCenter
                    text: root.isLoading ? "" : "🚀 FETCH MANGA"
                    loading: root.isLoading
                    enabled: urlInput.text.length > 0 && !root.isLoading
                    
                    onClicked: {
                        if (urlInput.text.trim() !== "") {
                            root.isLoading = true
                            bridge.fetchManga(urlInput.text.trim())
                        }
                    }
                }
            }
        }
        
        // ==================== Quick Actions ====================
        
        RowLayout {
            Layout.fillWidth: true
            Layout.leftMargin: Theme.spacingXXL
            Layout.rightMargin: Theme.spacingXXL
            spacing: Theme.spacingL
            
            GlassCard {
                Layout.fillWidth: true
                Layout.preferredHeight: 80
                
                RowLayout {
                    anchors.fill: parent
                    anchors.margins: Theme.spacingM
                    spacing: Theme.spacingM
                    
                    Text {
                        text: "⚙️"
                        font.pixelSize: 32
                    }
                    
                    ColumnLayout {
                        spacing: 2
                        
                        Text {
                            text: "Settings"
                            font.pixelSize: Theme.fontSizeLarge
                            font.bold: true
                            color: Theme.textPrimary
                        }
                        
                        Text {
                            text: "Configure download options"
                            font.pixelSize: Theme.fontSizeSmall
                            color: Theme.textSecondary
                        }
                    }
                    
                    Item { Layout.fillWidth: true }
                    
                    Text {
                        text: "→"
                        font.pixelSize: 24
                        color: Theme.textMuted
                    }
                }
                
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.openSettings()
                }
            }
        }
        
        // Spacer
        Item { Layout.fillHeight: true }
        
        // ==================== Footer ====================
        
        Text {
            Layout.alignment: Qt.AlignHCenter
            text: "Made with ❤️ by Yui007  •  v1.0.0"
            font.pixelSize: Theme.fontSizeSmall
            color: Theme.textMuted
        }
    }
    
    // ==================== Bridge Connections ====================
    
    Connections {
        target: bridge
        
        function onMangaLoaded(data) {
            root.isLoading = false
            root.mangaLoaded(data)
        }
        
        function onMangaError(error) {
            root.isLoading = false
        }
    }
}

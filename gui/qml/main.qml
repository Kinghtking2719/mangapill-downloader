import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "theme"
import "components"
import "screens"

/**
 * Main Application Window
 * Handles navigation and global state
 */
ApplicationWindow {
    id: root
    
    width: 1100
    height: 750
    minimumWidth: 900
    minimumHeight: 650
    visible: true
    title: "Mangapill Downloader"
    color: Theme.bgPrimary
    
    // ==================== Global State ====================
    
    property var currentManga: null
    property var selectedChapters: []
    property string currentScreen: "home"
    
    // ==================== Background ====================
    
    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: Theme.bgPrimary }
            GradientStop { position: 0.5; color: Theme.bgSecondary }
            GradientStop { position: 1.0; color: Theme.bgPrimary }
        }
    }
    
    // Animated background orb 1
    Rectangle {
        id: orb1
        width: 400
        height: 400
        radius: 200
        x: -100
        y: -100
        color: Theme.accentPrimary
        opacity: 0.05
        
        SequentialAnimation on x {
            loops: Animation.Infinite
            NumberAnimation { to: 100; duration: 8000; easing.type: Easing.InOutSine }
            NumberAnimation { to: -100; duration: 8000; easing.type: Easing.InOutSine }
        }
    }
    
    // Animated background orb 2
    Rectangle {
        id: orb2
        width: 300
        height: 300
        radius: 150
        x: parent.width - 200
        y: parent.height - 200
        color: Theme.accentSecondary
        opacity: 0.04
        
        SequentialAnimation on y {
            loops: Animation.Infinite
            NumberAnimation { to: root.height - 300; duration: 6000; easing.type: Easing.InOutSine }
            NumberAnimation { to: root.height - 200; duration: 6000; easing.type: Easing.InOutSine }
        }
    }
    
    // ==================== Screen Stack ====================
    
    StackView {
        id: stackView
        anchors.fill: parent
        anchors.margins: Theme.spacingL
        
        initialItem: homeScreen
        
        // Slide transitions
        pushEnter: Transition {
            PropertyAnimation {
                property: "opacity"
                from: 0
                to: 1
                duration: Theme.animNormal
            }
            PropertyAnimation {
                property: "x"
                from: 50
                to: 0
                duration: Theme.animSlow
                easing.type: Easing.OutCubic
            }
        }
        
        pushExit: Transition {
            PropertyAnimation {
                property: "opacity"
                from: 1
                to: 0
                duration: Theme.animNormal
            }
        }
        
        popEnter: Transition {
            PropertyAnimation {
                property: "opacity"
                from: 0
                to: 1
                duration: Theme.animNormal
            }
        }
        
        popExit: Transition {
            PropertyAnimation {
                property: "opacity"
                from: 1
                to: 0
                duration: Theme.animNormal
            }
            PropertyAnimation {
                property: "x"
                from: 0
                to: 50
                duration: Theme.animSlow
                easing.type: Easing.InCubic
            }
        }
    }
    
    // ==================== Screen Components ====================
    
    Component {
        id: homeScreen
        HomeScreen {
            onMangaLoaded: function(manga) {
                root.currentManga = manga
                stackView.push(mangaInfoScreen)
            }
            onOpenSettings: {
                stackView.push(settingsScreen)
            }
        }
    }
    
    Component {
        id: mangaInfoScreen
        MangaInfoScreen {
            manga: root.currentManga
            onBack: stackView.pop()
            onStartDownload: function(chapters) {
                root.selectedChapters = chapters
                stackView.push(downloadScreen)
            }
        }
    }
    
    Component {
        id: downloadScreen
        DownloadScreen {
            manga: root.currentManga
            selectedChapters: root.selectedChapters
            onBack: stackView.pop()
            onFinished: {
                stackView.pop(null) // Go back to home
            }
        }
    }
    
    Component {
        id: settingsScreen
        SettingsScreen {
            onBack: stackView.pop()
        }
    }
    
    // ==================== Bridge Connections ====================
    
    Connections {
        target: bridge
        
        function onMangaLoaded(data) {
            root.currentManga = data
        }
        
        function onMangaError(error) {
            errorPopup.show(error)
        }
        
        function onDownloadError(error) {
            errorPopup.show(error)
        }
    }
    
    // ==================== Error Popup ====================
    
    Popup {
        id: errorPopup
        anchors.centerIn: parent
        width: 400
        height: 150
        modal: true
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
        
        property string message: ""
        
        function show(msg) {
            message = msg
            open()
        }
        
        background: Rectangle {
            color: Theme.bgCard
            radius: Theme.radiusL
            border.color: Theme.error
            border.width: 2
            opacity: 0.95
        }
        
        contentItem: ColumnLayout {
            spacing: Theme.spacingM
            
            Text {
                text: "⚠️ Error"
                font.pixelSize: Theme.fontSizeXLarge
                font.bold: true
                color: Theme.error
                Layout.alignment: Qt.AlignHCenter
            }
            
            Text {
                text: errorPopup.message
                font.pixelSize: Theme.fontSizeMedium
                color: Theme.textPrimary
                wrapMode: Text.WordWrap
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
            }
            
            NeonButton {
                text: "OK"
                Layout.alignment: Qt.AlignHCenter
                onClicked: errorPopup.close()
            }
        }
        
        enter: Transition {
            NumberAnimation { property: "opacity"; from: 0; to: 1; duration: Theme.animFast }
            NumberAnimation { property: "scale"; from: 0.9; to: 1; duration: Theme.animNormal; easing.type: Easing.OutBack }
        }
        
        exit: Transition {
            NumberAnimation { property: "opacity"; from: 1; to: 0; duration: Theme.animFast }
        }
    }
}

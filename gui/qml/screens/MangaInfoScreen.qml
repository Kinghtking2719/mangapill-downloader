import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../theme"
import "../components"

/**
 * MangaInfoScreen - Display manga info and chapter selection
 */
Item {
    id: root
    
    property var manga: null
    property var selectedIndices: []
    property string selectionMode: "all"  // "all", "range", "custom"
    
    signal back()
    signal startDownload(var chapters)
    
    ColumnLayout {
        anchors.fill: parent
        spacing: Theme.spacingM
        
        // ==================== Header ====================
        
        RowLayout {
            Layout.fillWidth: true
            spacing: Theme.spacingM
            
            // Back button
            Rectangle {
                width: 44
                height: 44
                radius: Theme.radiusM
                color: backMouse.containsMouse ? Theme.bgCardHover : "transparent"
                border.color: Theme.borderLight
                border.width: 1
                
                Text {
                    anchors.centerIn: parent
                    text: "←"
                    font.pixelSize: 20
                    color: Theme.textPrimary
                }
                
                MouseArea {
                    id: backMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.back()
                }
            }
            
            Text {
                text: "📚 Manga Information"
                font.pixelSize: Theme.fontSizeXLarge
                font.bold: true
                color: Theme.textPrimary
            }
            
            Item { Layout.fillWidth: true }
        }
        
        // ==================== Manga Info ====================
        
        GlassCard {
            Layout.fillWidth: true
            Layout.preferredHeight: 200
            hoverable: false
            
            RowLayout {
                anchors.fill: parent
                anchors.margins: Theme.spacingL
                spacing: Theme.spacingL
                
                // Cover Image
                Rectangle {
                    width: 120
                    height: 170
                    radius: Theme.radiusM
                    color: Theme.bgCard
                    border.color: Theme.accentPrimary
                    border.width: 2
                    
                    Image {
                        anchors.fill: parent
                        anchors.margins: 2
                        source: root.manga ? root.manga.cover_url : ""
                        fillMode: Image.PreserveAspectCrop
                        
                        Rectangle {
                            anchors.fill: parent
                            color: Theme.bgCard
                            visible: parent.status !== Image.Ready
                            
                            Text {
                                anchors.centerIn: parent
                                text: "📖"
                                font.pixelSize: 40
                            }
                        }
                    }
                }
                
                // Info Grid
                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    spacing: Theme.spacingS
                    
                    Text {
                        text: root.manga ? root.manga.title : ""
                        font.pixelSize: Theme.fontSizeTitle
                        font.bold: true
                        color: Theme.textPrimary
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                    }
                    
                    GridLayout {
                        columns: 2
                        columnSpacing: Theme.spacingL
                        rowSpacing: Theme.spacingXS
                        
                        Text { text: "📘 Type:"; color: Theme.textSecondary; font.pixelSize: Theme.fontSizeMedium }
                        Text { text: root.manga ? root.manga.manga_type : ""; color: Theme.textPrimary; font.pixelSize: Theme.fontSizeMedium }
                        
                        Text { text: "📊 Status:"; color: Theme.textSecondary; font.pixelSize: Theme.fontSizeMedium }
                        Text { 
                            text: root.manga ? root.manga.status : ""
                            color: root.manga && root.manga.status === "completed" ? Theme.success : Theme.warning
                            font.pixelSize: Theme.fontSizeMedium
                        }
                        
                        Text { text: "📅 Year:"; color: Theme.textSecondary; font.pixelSize: Theme.fontSizeMedium }
                        Text { text: root.manga ? root.manga.year : ""; color: Theme.textPrimary; font.pixelSize: Theme.fontSizeMedium }
                        
                        Text { text: "📚 Chapters:"; color: Theme.textSecondary; font.pixelSize: Theme.fontSizeMedium }
                        Text { text: root.manga ? root.manga.chapters_count.toString() : "0"; color: Theme.accentPrimary; font.bold: true; font.pixelSize: Theme.fontSizeMedium }
                    }
                    
                    // Genres
                    Flow {
                        Layout.fillWidth: true
                        spacing: Theme.spacingXS
                        
                        Repeater {
                            model: root.manga ? root.manga.genres.slice(0, 5) : []
                            
                            Rectangle {
                                width: genreText.width + 16
                                height: 24
                                radius: 12
                                color: Theme.bgCardHover
                                border.color: Theme.borderLight
                                
                                Text {
                                    id: genreText
                                    anchors.centerIn: parent
                                    text: modelData
                                    font.pixelSize: Theme.fontSizeSmall
                                    color: Theme.textSecondary
                                }
                            }
                        }
                    }
                }
            }
        }
        
        // ==================== Selection Mode ====================
        
        RowLayout {
            Layout.fillWidth: true
            spacing: Theme.spacingM
            
            Text {
                text: "📑 Select Chapters:"
                font.pixelSize: Theme.fontSizeLarge
                font.bold: true
                color: Theme.textPrimary
            }
            
            Item { Layout.fillWidth: true }
            
            // Mode buttons
            Repeater {
                model: [
                    { id: "all", label: "⭕ All", icon: "" },
                    { id: "range", label: "🔢 Range", icon: "" },
                    { id: "custom", label: "✅ Custom", icon: "" }
                ]
                
                Rectangle {
                    width: modeText.width + 24
                    height: 36
                    radius: Theme.radiusM
                    color: root.selectionMode === modelData.id ? Theme.accentPrimary : Theme.bgCard
                    border.color: root.selectionMode === modelData.id ? Theme.accentPrimary : Theme.borderLight
                    
                    Text {
                        id: modeText
                        anchors.centerIn: parent
                        text: modelData.label
                        font.pixelSize: Theme.fontSizeMedium
                        color: root.selectionMode === modelData.id ? Theme.bgPrimary : Theme.textPrimary
                    }
                    
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            root.selectionMode = modelData.id
                            updateSelection()
                        }
                    }
                    
                    Behavior on color { ColorAnimation { duration: Theme.animFast } }
                }
            }
        }
        
        // Range input (visible when range mode)
        RowLayout {
            Layout.fillWidth: true
            visible: root.selectionMode === "range"
            spacing: Theme.spacingM
            
            Text {
                text: "From:"
                color: Theme.textSecondary
            }
            
            TextField {
                id: rangeFrom
                implicitWidth: 80
                text: "1"
                color: Theme.textPrimary
                horizontalAlignment: Text.AlignHCenter
                background: Rectangle {
                    radius: Theme.radiusS
                    color: Theme.bgCard
                    border.color: Theme.borderLight
                }
                onTextChanged: updateSelection()
            }
            
            Text {
                text: "To:"
                color: Theme.textSecondary
            }
            
            TextField {
                id: rangeTo
                implicitWidth: 80
                text: root.manga ? root.manga.chapters_count.toString() : "1"
                color: Theme.textPrimary
                horizontalAlignment: Text.AlignHCenter
                background: Rectangle {
                    radius: Theme.radiusS
                    color: Theme.bgCard
                    border.color: Theme.borderLight
                }
                onTextChanged: updateSelection()
            }
            
            Item { Layout.fillWidth: true }
        }
        
        // ==================== Chapter Grid ====================
        
        GlassCard {
            Layout.fillWidth: true
            Layout.fillHeight: true
            hoverable: false
            
            ScrollView {
                anchors.fill: parent
                anchors.margins: Theme.spacingM
                clip: true
                
                GridLayout {
                    width: parent.width
                    columns: 4
                    columnSpacing: Theme.spacingS
                    rowSpacing: Theme.spacingS
                    
                    Repeater {
                        id: chapterRepeater
                        model: root.manga ? root.manga.chapters : []
                        
                        ChapterItem {
                            title: modelData.title
                            index: model.index
                            selected: root.selectedIndices.indexOf(model.index) !== -1
                            
                            onToggled: function(checked) {
                                if (root.selectionMode === "custom") {
                                    if (checked) {
                                        if (root.selectedIndices.indexOf(index) === -1) {
                                            root.selectedIndices = root.selectedIndices.concat([index])
                                        }
                                    } else {
                                        root.selectedIndices = root.selectedIndices.filter(i => i !== index)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        
        // ==================== Format & Download ====================
        
        GlassCard {
            Layout.fillWidth: true
            Layout.preferredHeight: 80
            hoverable: false
            
            RowLayout {
                anchors.fill: parent
                anchors.margins: Theme.spacingM
                spacing: Theme.spacingL
                
                // Format selection
                ColumnLayout {
                    spacing: Theme.spacingXS
                    
                    Text {
                        text: "📄 Format"
                        font.pixelSize: Theme.fontSizeSmall
                        color: Theme.textSecondary
                    }
                    
                    RowLayout {
                        spacing: Theme.spacingS
                        
                        Repeater {
                            model: ["images", "pdf", "cbz"]
                            
                            Rectangle {
                                width: 70
                                height: 32
                                radius: Theme.radiusS
                                color: bridge.outputFormat === modelData ? Theme.accentPrimary : Theme.bgCard
                                border.color: Theme.borderLight
                                
                                Text {
                                    anchors.centerIn: parent
                                    text: modelData.toUpperCase()
                                    font.pixelSize: Theme.fontSizeSmall
                                    font.bold: true
                                    color: bridge.outputFormat === modelData ? Theme.bgPrimary : Theme.textPrimary
                                }
                                
                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: bridge.outputFormat = modelData
                                }
                            }
                        }
                    }
                }
                
                // Keep images toggle
                ColumnLayout {
                    spacing: Theme.spacingXS
                    visible: bridge.outputFormat !== "images"
                    
                    Text {
                        text: "🖼️ Keep Images"
                        font.pixelSize: Theme.fontSizeSmall
                        color: Theme.textSecondary
                    }
                    
                    ToggleSwitch {
                        checked: bridge.keepImages
                        onCheckedChanged: bridge.keepImages = checked
                    }
                }
                
                Item { Layout.fillWidth: true }
                
                // Download button
                NeonButton {
                    text: "📥 DOWNLOAD (" + root.selectedIndices.length + ")"
                    enabled: root.selectedIndices.length > 0
                    accentColor: Theme.success
                    
                    onClicked: {
                        root.startDownload(root.selectedIndices)
                    }
                }
            }
        }
    }
    
    function updateSelection() {
        if (!root.manga) return
        
        var total = root.manga.chapters_count
        
        if (root.selectionMode === "all") {
            var allIndices = []
            for (var i = 0; i < total; i++) {
                allIndices.push(i)
            }
            root.selectedIndices = allIndices
        } else if (root.selectionMode === "range") {
            var from = Math.max(1, parseInt(rangeFrom.text) || 1) - 1
            var to = Math.min(total, parseInt(rangeTo.text) || total) - 1
            var rangeIndices = []
            for (var j = from; j <= to; j++) {
                rangeIndices.push(j)
            }
            root.selectedIndices = rangeIndices
        }
        // Custom mode - selection handled by ChapterItem clicks
    }
    
    Component.onCompleted: {
        if (root.manga) {
            rangeTo.text = root.manga.chapters_count.toString()
            updateSelection()
        }
    }
    
    onMangaChanged: {
        if (root.manga) {
            rangeTo.text = root.manga.chapters_count.toString()
            updateSelection()
        }
    }
}

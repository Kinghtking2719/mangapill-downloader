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
    property string selectionMode: "all"  // "all", "none", "custom"
    
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
            
            // Download button in header
            NeonButton {
                text: "📥 DOWNLOAD (" + root.selectedIndices.length + ")"
                enabled: root.selectedIndices.length > 0
                accentColor: Theme.success
                
                onClicked: {
                    root.startDownload(root.selectedIndices)
                }
            }
        }
        
        // ==================== Manga Info Card ====================
        
        GlassCard {
            Layout.fillWidth: true
            Layout.preferredHeight: 240
            hoverable: false
            
            RowLayout {
                anchors.fill: parent
                anchors.margins: Theme.spacingL
                spacing: Theme.spacingL
                
                // Cover Image - uses local downloaded file
                Rectangle {
                    width: 140
                    height: 200
                    radius: Theme.radiusM
                    color: Theme.bgCard
                    border.color: Theme.accentPrimary
                    border.width: 2
                    
                    Image {
                        anchors.fill: parent
                        anchors.margins: 2
                        // Use local cover path if available
                        source: root.manga && root.manga.cover_local ? 
                            "file:///" + root.manga.cover_local : ""
                        fillMode: Image.PreserveAspectCrop
                        
                        Rectangle {
                            anchors.fill: parent
                            color: Theme.bgCard
                            visible: parent.status !== Image.Ready
                            
                            Column {
                                anchors.centerIn: parent
                                spacing: 4
                                
                                Text {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    text: "📖"
                                    font.pixelSize: 40
                                }
                                
                                Text {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    text: "Loading..."
                                    font.pixelSize: 10
                                    color: Theme.textMuted
                                    visible: root.manga && root.manga.cover_local
                                }
                            }
                        }
                    }
                }
                
                // Info Column
                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    spacing: Theme.spacingS
                    
                    // Title
                    Text {
                        text: root.manga ? root.manga.title : ""
                        font.pixelSize: Theme.fontSizeTitle
                        font.bold: true
                        color: Theme.textPrimary
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                    }
                    
                    // Description
                    Text {
                        text: root.manga && root.manga.description ? 
                            root.manga.description : "No description available."
                        font.pixelSize: Theme.fontSizeSmall
                        color: Theme.textSecondary
                        wrapMode: Text.WordWrap
                        elide: Text.ElideRight
                        maximumLineCount: 3
                        Layout.fillWidth: true
                    }
                    
                    // Metadata Grid
                    GridLayout {
                        columns: 4
                        columnSpacing: Theme.spacingL
                        rowSpacing: Theme.spacingXS
                        
                        Text { text: "📘 Type:"; color: Theme.textMuted; font.pixelSize: Theme.fontSizeSmall }
                        Text { text: root.manga ? root.manga.manga_type : ""; color: Theme.textPrimary; font.pixelSize: Theme.fontSizeSmall }
                        
                        Text { text: "📊 Status:"; color: Theme.textMuted; font.pixelSize: Theme.fontSizeSmall }
                        Text { 
                            text: root.manga ? root.manga.status : ""
                            color: root.manga && root.manga.status === "completed" ? Theme.success : Theme.warning
                            font.pixelSize: Theme.fontSizeSmall
                            font.bold: true
                        }
                        
                        Text { text: "📅 Year:"; color: Theme.textMuted; font.pixelSize: Theme.fontSizeSmall }
                        Text { text: root.manga ? root.manga.year : ""; color: Theme.textPrimary; font.pixelSize: Theme.fontSizeSmall }
                        
                        Text { text: "📚 Chapters:"; color: Theme.textMuted; font.pixelSize: Theme.fontSizeSmall }
                        Text { text: root.manga ? root.manga.chapters_count.toString() : "0"; color: Theme.accentPrimary; font.bold: true; font.pixelSize: Theme.fontSizeSmall }
                    }
                    
                    // Genres
                    Flow {
                        Layout.fillWidth: true
                        spacing: Theme.spacingXS
                        
                        Repeater {
                            model: root.manga ? root.manga.genres.slice(0, 6) : []
                            
                            Rectangle {
                                width: genreText.width + 12
                                height: 22
                                radius: 11
                                color: Theme.bgCardHover
                                border.color: Theme.borderLight
                                
                                Text {
                                    id: genreText
                                    anchors.centerIn: parent
                                    text: modelData
                                    font.pixelSize: 10
                                    color: Theme.textSecondary
                                }
                            }
                        }
                    }
                }
            }
        }
        
        // ==================== Chapter Selection Header ====================
        
        RowLayout {
            Layout.fillWidth: true
            spacing: Theme.spacingM
            
            Text {
                text: "📑 Select Chapters"
                font.pixelSize: Theme.fontSizeLarge
                font.bold: true
                color: Theme.textPrimary
            }
            
            Item { Layout.fillWidth: true }
            
            // ALL button
            Rectangle {
                id: allBtn
                width: 80
                height: 36
                radius: Theme.radiusM
                color: root.selectionMode === "all" ? Theme.accentPrimary : Theme.bgCard
                border.color: root.selectionMode === "all" ? Theme.accentPrimary : Theme.borderLight
                border.width: root.selectionMode === "all" ? 0 : 1
                
                Text {
                    anchors.centerIn: parent
                    text: "✓ ALL"
                    font.pixelSize: Theme.fontSizeMedium
                    font.bold: true
                    color: root.selectionMode === "all" ? Theme.bgPrimary : Theme.textPrimary
                }
                
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: selectAll()
                }
                
                Behavior on color { ColorAnimation { duration: Theme.animFast } }
            }
            
            // NONE button
            Rectangle {
                id: noneBtn
                width: 80
                height: 36
                radius: Theme.radiusM
                color: root.selectionMode === "none" ? Theme.error : Theme.bgCard
                border.color: root.selectionMode === "none" ? Theme.error : Theme.borderLight
                border.width: root.selectionMode === "none" ? 0 : 1
                
                Text {
                    anchors.centerIn: parent
                    text: "✗ NONE"
                    font.pixelSize: Theme.fontSizeMedium
                    font.bold: true
                    color: root.selectionMode === "none" ? Theme.textPrimary : Theme.textPrimary
                }
                
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: selectNone()
                }
                
                Behavior on color { ColorAnimation { duration: Theme.animFast } }
            }
            
            // Range input
            Text {
                text: "Range:"
                color: Theme.textSecondary
                font.pixelSize: Theme.fontSizeMedium
            }
            
            TextField {
                id: rangeFrom
                implicitWidth: 60
                text: "1"
                color: Theme.textPrimary
                horizontalAlignment: Text.AlignHCenter
                background: Rectangle {
                    radius: Theme.radiusS
                    color: Theme.bgCard
                    border.color: Theme.borderLight
                }
                onTextChanged: selectRange()
            }
            
            Text {
                text: "-"
                color: Theme.textSecondary
            }
            
            TextField {
                id: rangeTo
                implicitWidth: 60
                text: root.manga ? root.manga.chapters_count.toString() : "1"
                color: Theme.textPrimary
                horizontalAlignment: Text.AlignHCenter
                background: Rectangle {
                    radius: Theme.radiusS
                    color: Theme.bgCard
                    border.color: Theme.borderLight
                }
                onTextChanged: selectRange()
            }
            
            NeonButton {
                text: "Apply"
                implicitWidth: 70
                onClicked: selectRange()
            }
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
                    columns: 5
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
                                toggleChapter(model.index, checked)
                            }
                        }
                    }
                }
            }
        }
    }
    
    // ==================== Functions ====================
    
    function selectAll() {
        if (!root.manga) return
        var allIndices = []
        for (var i = 0; i < root.manga.chapters_count; i++) {
            allIndices.push(i)
        }
        root.selectedIndices = allIndices
        root.selectionMode = "all"
    }
    
    function selectNone() {
        root.selectedIndices = []
        root.selectionMode = "none"
    }
    
    function selectRange() {
        if (!root.manga) return
        var from = Math.max(1, parseInt(rangeFrom.text) || 1) - 1
        var to = Math.min(root.manga.chapters_count, parseInt(rangeTo.text) || root.manga.chapters_count) - 1
        var rangeIndices = []
        for (var j = from; j <= to; j++) {
            rangeIndices.push(j)
        }
        root.selectedIndices = rangeIndices
        root.selectionMode = "custom"
    }
    
    function toggleChapter(index, checked) {
        root.selectionMode = "custom"  // Switch to custom when manually toggling
        if (checked) {
            if (root.selectedIndices.indexOf(index) === -1) {
                root.selectedIndices = root.selectedIndices.concat([index])
            }
        } else {
            root.selectedIndices = root.selectedIndices.filter(function(i) { return i !== index })
        }
    }
    
    Component.onCompleted: {
        if (root.manga) {
            rangeTo.text = root.manga.chapters_count.toString()
            selectAll()  // Select all by default
        }
    }
    
    onMangaChanged: {
        if (root.manga) {
            rangeTo.text = root.manga.chapters_count.toString()
            selectAll()  // Select all by default
        }
    }
}

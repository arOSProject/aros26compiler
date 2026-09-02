import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../components"

ARWindow {
    id: root
    appTitle: "Files"
    appGlyph: "▰"
    property string currentPath: ARSystem.homePath()
    property var entries: []
    property string selectedPath: ""
    property string selectedName: ""
    property bool gridMode: true

    function refresh() { entries = ARSystem.listDirectory(currentPath) }
    function navigate(path) { currentPath = path; selectedPath = ""; refresh() }
    Component.onCompleted: refresh()

    RowLayout {
        anchors.fill: parent
        spacing: 0

        GlassPanel {
            Layout.preferredWidth: 230
            Layout.fillHeight: true
            radius: 0
            border.width: 0
            theme: root.theme
            color: root.theme.dark ? "#6f2e2844" : "#72ffffff"

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 16
                spacing: 6
                Text { text: "Folders"; color: root.theme.mutedText; font.family: root.theme.fontFamily; font.pixelSize: 11; font.weight: Font.DemiBold; leftPadding: 10 }
                Repeater {
                    model: [
                        { name: "Home", glyph: "⌂", path: ARSystem.homePath() },
                        { name: "Desktop", glyph: "▣", path: ARSystem.homePath() + "/Desktop" },
                        { name: "Documents", glyph: "□", path: ARSystem.homePath() + "/Documents" },
                        { name: "Downloads", glyph: "↓", path: ARSystem.homePath() + "/Downloads" },
                        { name: "Pictures", glyph: "▧", path: ARSystem.homePath() + "/Pictures" },
                        { name: "Music", glyph: "♫", path: ARSystem.homePath() + "/Music" },
                        { name: "Videos", glyph: "▷", path: ARSystem.homePath() + "/Videos" }
                    ]
                    delegate: NavItem {
                        Layout.fillWidth: true
                        theme: root.theme
                        text: modelData.name
                        glyph: modelData.glyph
                        selected: root.currentPath === modelData.path
                        onClicked: root.navigate(modelData.path)
                    }
                }
                Rectangle { Layout.fillWidth: true; height: 1; color: root.theme.divider; Layout.topMargin: 8; Layout.bottomMargin: 8 }
                Text { text: "Storage"; color: root.theme.mutedText; font.family: root.theme.fontFamily; font.pixelSize: 11; font.weight: Font.DemiBold; leftPadding: 10 }
                Repeater {
                    model: ARSystem.volumes()
                    delegate: RowLayout {
                        Layout.fillWidth: true
                        spacing: 2
                        NavItem { Layout.fillWidth: true; theme: root.theme; text: modelData.name; glyph: modelData.readOnly ? "◇" : "◆"; selected: root.currentPath === modelData.path; onClicked: root.navigate(modelData.path) }
                        ARButton { visible: modelData.canUnmount; theme: root.theme; text: "⏏"; quiet: true; implicitWidth: 34; onClicked: ARSystem.unmountVolume(modelData.device) }
                    }
                }
                NavItem { Layout.fillWidth: true; theme: root.theme; text: "Trash"; glyph: "⌫"; onClicked: root.navigate(ARSystem.homePath() + "/.local/share/Trash/files") }
                Item { Layout.fillHeight: true }
                Text { text: "Drop files into this window to copy them"; color: root.theme.mutedText; font.family: root.theme.fontFamily; font.pixelSize: 10; wrapMode: Text.Wrap; Layout.fillWidth: true; leftPadding: 10; rightPadding: 10 }
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 0

            RowLayout {
                Layout.fillWidth: true
                Layout.preferredHeight: 66
                Layout.leftMargin: 18
                Layout.rightMargin: 18
                spacing: 8
                ARButton { theme: root.theme; text: "←"; quiet: true; onClicked: root.navigate(ARSystem.parentPath(root.currentPath)) }
                ARButton { theme: root.theme; text: "⌂"; quiet: true; onClicked: root.navigate(ARSystem.homePath()) }
                GlassPanel {
                    theme: root.theme
                    Layout.fillWidth: true
                    Layout.preferredHeight: 42
                    radius: 21
                    Text { anchors.fill: parent; anchors.leftMargin: 16; anchors.rightMargin: 16; verticalAlignment: Text.AlignVCenter; text: root.currentPath.replace(ARSystem.homePath(), "Home"); color: root.theme.secondaryText; font.family: root.theme.fontFamily; font.pixelSize: 13; elide: Text.ElideMiddle }
                }
                ARButton { theme: root.theme; text: "+ Folder"; primary: true; onClicked: newFolderDialog.open() }
                ARButton { theme: root.theme; text: root.gridMode ? "☷" : "▦"; onClicked: root.gridMode = !root.gridMode }
            }

            Rectangle { Layout.fillWidth: true; height: 1; color: root.theme.divider }

            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true
                DropArea {
                    anchors.fill: parent
                    onDropped: {
                        var values = []
                        for (var i = 0; i < drop.urls.length; ++i) values.push(drop.urls[i].toString())
                        ARSystem.copyUrls(values, root.currentPath)
                        root.refresh()
                    }
                }

                GridView {
                    id: grid
                    anchors.fill: parent
                    anchors.margins: 22
                    visible: root.gridMode
                    clip: true
                    cellWidth: 170
                    cellHeight: 136
                    model: root.entries
                    delegate: GlassPanel {
                        width: 154
                        height: 118
                        theme: root.theme
                        radius: root.theme.radius
                        color: root.selectedPath === modelData.path ? "#4d8d4cff" : root.theme.softSurface
                        Column {
                            anchors.fill: parent
                            anchors.margins: 14
                            spacing: 7
                            ARIcon { theme: root.theme; glyph: modelData.isDir ? "▰" : "□"; tint: modelData.isDir ? root.theme.accent : root.theme.blue; width: 44; height: 44; round: false }
                            Text { width: parent.width; text: modelData.name; color: root.theme.text; font.family: root.theme.fontFamily; font.pixelSize: 13; font.weight: Font.DemiBold; elide: Text.ElideRight }
                            Text { width: parent.width; text: modelData.isDir ? "Folder" : modelData.size; color: root.theme.secondaryText; font.family: root.theme.fontFamily; font.pixelSize: 10; elide: Text.ElideRight }
                        }
                        MouseArea {
                            anchors.fill: parent
                            acceptedButtons: Qt.LeftButton | Qt.RightButton
                            onClicked: function(mouse) {
                                root.selectedPath = modelData.path
                                root.selectedName = modelData.name
                                if (mouse.button === Qt.RightButton) fileMenu.popup()
                            }
                            onDoubleClicked: modelData.isDir ? root.navigate(modelData.path) : ARSystem.openPath(modelData.path)
                        }
                    }
                }

                ListView {
                    id: list
                    anchors.fill: parent
                    anchors.margins: 18
                    visible: !root.gridMode
                    clip: true
                    spacing: 4
                    model: root.entries
                    header: RowLayout {
                        width: list.width
                        height: 32
                        Text { text: "Name"; color: root.theme.mutedText; font.family: root.theme.fontFamily; font.pixelSize: 11; Layout.fillWidth: true }
                        Text { text: "Modified"; color: root.theme.mutedText; font.family: root.theme.fontFamily; font.pixelSize: 11; Layout.preferredWidth: 170 }
                        Text { text: "Size"; color: root.theme.mutedText; font.family: root.theme.fontFamily; font.pixelSize: 11; Layout.preferredWidth: 90 }
                    }
                    delegate: Rectangle {
                        width: list.width
                        height: 48
                        radius: 12
                        color: root.selectedPath === modelData.path ? "#438d4cff" : rowMouse.containsMouse ? root.theme.softSurface : "transparent"
                        RowLayout {
                            anchors.fill: parent; anchors.leftMargin: 10; anchors.rightMargin: 10; spacing: 10
                            ARIcon { theme: root.theme; glyph: modelData.isDir ? "▰" : "□"; tint: modelData.isDir ? root.theme.accent : root.theme.blue; width: 32; height: 32; round: false }
                            Text { text: modelData.name; color: root.theme.text; font.family: root.theme.fontFamily; font.pixelSize: 13; elide: Text.ElideRight; Layout.fillWidth: true }
                            Text { text: modelData.modified; color: root.theme.secondaryText; font.family: root.theme.fontFamily; font.pixelSize: 11; Layout.preferredWidth: 170 }
                            Text { text: modelData.size; color: root.theme.secondaryText; font.family: root.theme.fontFamily; font.pixelSize: 11; Layout.preferredWidth: 90 }
                        }
                        MouseArea {
                            id: rowMouse; anchors.fill: parent; hoverEnabled: true; acceptedButtons: Qt.LeftButton | Qt.RightButton
                            onClicked: function(mouse) { root.selectedPath = modelData.path; root.selectedName = modelData.name; if (mouse.button === Qt.RightButton) fileMenu.popup() }
                            onDoubleClicked: modelData.isDir ? root.navigate(modelData.path) : ARSystem.openPath(modelData.path)
                        }
                    }
                }

                Text { anchors.centerIn: parent; visible: root.entries.length === 0; text: "This folder is empty"; color: root.theme.secondaryText; font.family: root.theme.fontFamily; font.pixelSize: 15 }
            }
        }
    }

    Menu {
        id: fileMenu
        MenuItem { text: "Open"; enabled: root.selectedPath.length > 0; onTriggered: ARSystem.openPath(root.selectedPath) }
        MenuItem { text: "Rename"; enabled: root.selectedPath.length > 0; onTriggered: { renameField.text = root.selectedName; renameDialog.open() } }
        MenuSeparator { }
        MenuItem { text: "Move to Trash"; enabled: root.selectedPath.length > 0; onTriggered: trashDialog.open() }
    }

    Dialog {
        id: newFolderDialog
        title: "New folder"
        modal: true
        anchors.centerIn: parent
        standardButtons: Dialog.Ok | Dialog.Cancel
        onAccepted: { if (ARSystem.createFolder(root.currentPath, folderName.text)) root.refresh(); folderName.clear() }
        TextField { id: folderName; width: 300; placeholderText: "Folder name" }
    }
    Dialog {
        id: renameDialog
        title: "Rename"
        modal: true
        anchors.centerIn: parent
        standardButtons: Dialog.Ok | Dialog.Cancel
        onAccepted: { if (ARSystem.renamePath(root.selectedPath, renameField.text)) root.refresh() }
        TextField { id: renameField; width: 300 }
    }
    Dialog {
        id: trashDialog
        title: "Move item to Trash?"
        modal: true
        anchors.centerIn: parent
        standardButtons: Dialog.Yes | Dialog.Cancel
        onAccepted: { ARSystem.moveToTrash(root.selectedPath); root.selectedPath = ""; root.refresh() }
        Text { text: "You can recover it later from Trash."; color: root.theme.text; font.family: root.theme.fontFamily }
    }
}

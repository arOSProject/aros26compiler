import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window
import "../components"

Item {
    id: shell
    width: 1
    height: 1
    property var theme: Theme { }
    property var searchResults: ARSystem.applications.slice(0, 35)
    property bool showHiddenDesktopItems: false

    function wallpaperSource() {
        return ARSystem.wallpaper === "night"
                ? "qrc:/qt/qml/AROS/assets/wallpapers/ar-night.svg"
                : "qrc:/qt/qml/AROS/assets/wallpapers/ar-ribbon.svg"
    }

    Window {
        id: desktop
        title: "AR Desktop"
        visible: true
        visibility: Window.FullScreen
        color: "#d8b9ff"
        flags: Qt.Window | Qt.FramelessWindowHint | Qt.WindowStaysOnBottomHint

        Image {
            anchors.fill: parent
            source: shell.wallpaperSource()
            fillMode: Image.PreserveAspectCrop
            asynchronous: true
            Behavior on opacity { NumberAnimation { duration: 360 } }
        }

        Column {
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.leftMargin: 42
            anchors.topMargin: 92
            spacing: 12
            Repeater {
                model: [
                    { name: "Home", glyph: "⌂", action: "files" },
                    { name: "Install AR OS", glyph: "↓", action: "installer" }
                ]
                delegate: Column {
                    width: 84
                    spacing: 5
                    ARIcon { anchors.horizontalCenter: parent.horizontalCenter; theme: shell.theme; glyph: modelData.glyph; tint: index === 0 ? shell.theme.orange : shell.theme.accent; width: 48; height: 48; round: false }
                    Text { width: parent.width; text: modelData.name; horizontalAlignment: Text.AlignHCenter; wrapMode: Text.Wrap; color: shell.theme.dark ? "white" : shell.theme.text; font.family: shell.theme.fontFamily; font.pixelSize: 12; style: Text.Outline; styleColor: "#40ffffff" }
                    MouseArea { anchors.fill: parent; onDoubleClicked: ARSystem.launchCommand(modelData.action) }
                }
            }
        }

        GlassPanel {
            visible: Screen.width > 1200
            theme: shell.theme
            width: 280
            height: 126
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.rightMargin: 38
            anchors.topMargin: 88
            radius: shell.theme.radiusLarge
            Column {
                anchors.fill: parent
                anchors.margins: 18
                spacing: 8
                Text { text: Qt.formatDate(new Date(), "dddd, d MMMM"); color: shell.theme.secondaryText; font.family: shell.theme.fontFamily; font.pixelSize: 13 }
                Text { text: Qt.formatTime(new Date(), "hh:mm"); color: shell.theme.text; font.family: shell.theme.fontFamily; font.pixelSize: 34; font.weight: Font.Light }
                Text { text: ARSystem.networkName.length ? "Connected to " + ARSystem.networkName : "Ready when you are"; color: shell.theme.secondaryText; font.family: shell.theme.fontFamily; font.pixelSize: 12 }
            }
        }
    }

    Window {
        id: topBar
        title: "AR Top Bar"
        visible: true
        x: Math.round((Screen.width - width) / 2)
        y: 16
        width: Math.min(820, Screen.width - 32)
        height: 50
        color: "transparent"
        flags: Qt.Tool | Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint

        RowLayout {
            anchors.fill: parent
            spacing: 8
            ARIcon {
                theme: shell.theme
                glyph: "ϟ"
                tint: shell.theme.accent
                Layout.preferredWidth: 48
                Layout.preferredHeight: 48
                MouseArea { anchors.fill: parent; onClicked: { launcher.visible = !launcher.visible; if (launcher.visible) search.forceActiveFocus() } }
            }
            GlassPanel {
                theme: shell.theme
                Layout.fillWidth: true
                Layout.preferredHeight: 48
                radius: 24
                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 16
                    anchors.rightMargin: 12
                    Text { text: "✦"; color: shell.theme.accent2; font.pixelSize: 17 }
                    Text {
                        text: "What do you want to do?"
                        color: shell.theme.secondaryText
                        font.family: shell.theme.fontFamily
                        font.pixelSize: 13
                        Layout.fillWidth: true
                    }
                    Text { text: "⌕"; color: shell.theme.text; font.pixelSize: 20 }
                    MouseArea { anchors.fill: parent; onClicked: { launcher.visible = true; search.forceActiveFocus() } }
                }
            }
            GlassPanel {
                theme: shell.theme
                Layout.preferredWidth: 238
                Layout.preferredHeight: 48
                radius: 24
                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 15
                    anchors.rightMargin: 10
                    spacing: 10
                    Text { text: ARSystem.wifiEnabled ? "●" : "○"; color: ARSystem.wifiEnabled ? shell.theme.blue : shell.theme.mutedText; font.pixelSize: 12 }
                    Text { text: "◖"; color: shell.theme.text; font.pixelSize: 15 }
                    Text { text: ARSystem.battery >= 0 ? ARSystem.battery + "%" : "AC"; color: shell.theme.secondaryText; font.family: shell.theme.fontFamily; font.pixelSize: 12 }
                    Text { text: Qt.formatDateTime(new Date(), "ddd d  hh:mm"); color: shell.theme.text; font.family: shell.theme.fontFamily; font.pixelSize: 12; Layout.fillWidth: true }
                    ARIcon { theme: shell.theme; glyph: "ϟ"; tint: shell.theme.accent; width: 32; height: 32 }
                    MouseArea { anchors.fill: parent; onClicked: quickControls.visible = !quickControls.visible }
                }
            }
        }
    }

    Window {
        id: dock
        title: "AR Dock"
        visible: true
        x: Math.round((Screen.width - width) / 2)
        y: Screen.height - height - 18
        width: 418
        height: 68
        color: "transparent"
        flags: Qt.Tool | Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint

        GlassPanel {
            anchors.fill: parent
            theme: shell.theme
            radius: 34
            strong: true
            Row {
                anchors.centerIn: parent
                spacing: 10
                Repeater {
                    model: [
                        { glyph: "⌂", tint: shell.theme.orange, command: "files", tip: "Files" },
                        { glyph: "◉", tint: shell.theme.accent2, command: "software", tip: "Software" },
                        { glyph: ">_", tint: shell.theme.blue, command: "terminal", tip: "Terminal" },
                        { glyph: "✈", tint: shell.theme.cyan, command: "files", tip: "Browse" },
                        { glyph: "⚙", tint: "#6e6578", command: "settings", tip: "Settings" },
                        { glyph: "ϟ", tint: shell.theme.accent, command: "launcher", tip: "All apps" }
                    ]
                    delegate: Item {
                        width: 48
                        height: 52
                        ARIcon {
                            anchors.horizontalCenter: parent.horizontalCenter
                            y: iconMouse.containsMouse ? -3 : 2
                            width: iconMouse.containsMouse ? 48 : 44
                            height: width
                            theme: shell.theme
                            glyph: modelData.glyph
                            tint: modelData.tint
                            Behavior on y { NumberAnimation { duration: 130 } }
                            Behavior on width { NumberAnimation { duration: 130 } }
                        }
                        MouseArea {
                            id: iconMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: {
                                if (modelData.command === "launcher") launcher.visible = !launcher.visible
                                else ARSystem.launchCommand(modelData.command)
                            }
                        }
                    }
                }
            }
        }
    }

    Window {
        id: launcher
        title: "AR Launcher"
        visible: false
        visibility: visible ? Window.FullScreen : Window.Windowed
        color: "#300e0822"
        flags: Qt.Tool | Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint

        MouseArea { anchors.fill: parent; onClicked: launcher.visible = false }
        GlassPanel {
            id: launcherPanel
            theme: shell.theme
            anchors.fill: parent
            anchors.margins: Math.max(24, Math.min(parent.width, parent.height) * 0.055)
            radius: shell.theme.radiusLarge
            color: shell.theme.dark ? "#d81b1530" : "#d9bc8ae0"
            strong: true
            MouseArea { anchors.fill: parent }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 34
                spacing: 20
                Text {
                    text: "Good " + (new Date().getHours() < 12 ? "morning" : new Date().getHours() < 18 ? "afternoon" : "evening") + ", " + ARSystem.displayName + "!"
                    color: shell.theme.text
                    font.family: shell.theme.fontFamily
                    font.pixelSize: 28
                    font.weight: Font.DemiBold
                    Layout.alignment: Qt.AlignHCenter
                }
                TextField {
                    id: search
                    Layout.alignment: Qt.AlignHCenter
                    Layout.preferredWidth: Math.min(560, launcherPanel.width - 100)
                    Layout.preferredHeight: 48
                    placeholderText: "Search apps, settings, and files"
                    color: shell.theme.text
                    font.family: shell.theme.fontFamily
                    font.pixelSize: 14
                    leftPadding: 18
                    rightPadding: 18
                    background: GlassPanel { theme: shell.theme; radius: 24; strong: true }
                    onTextChanged: shell.searchResults = ARSystem.search(text)
                    Keys.onEscapePressed: launcher.visible = false
                }
                GridView {
                    id: appGrid
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    cellWidth: Math.max(116, width / Math.max(4, Math.floor(width / 128)))
                    cellHeight: 108
                    clip: true
                    model: shell.searchResults
                    delegate: Item {
                        width: appGrid.cellWidth
                        height: appGrid.cellHeight
                        Column {
                            anchors.centerIn: parent
                            spacing: 8
                            ARIcon {
                                anchors.horizontalCenter: parent.horizontalCenter
                                width: 54; height: 54
                                theme: shell.theme
                                glyph: modelData.type === "file" ? (modelData.path && modelData.path.indexOf(".") < 0 ? "▰" : "□") : modelData.name.substring(0, 1).toUpperCase()
                                tint: Qt.hsla((index * 0.137 + 0.62) % 1, 0.72, 0.57, 1)
                            }
                            Text { width: appGrid.cellWidth - 16; horizontalAlignment: Text.AlignHCenter; elide: Text.ElideRight; text: modelData.name; color: shell.theme.text; font.family: shell.theme.fontFamily; font.pixelSize: 12 }
                        }
                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: {
                                if (modelData.type === "application") ARSystem.launchDesktop(modelData.id)
                                else if (modelData.type === "setting") ARSystem.launchCommand(modelData.action)
                                else ARSystem.openPath(modelData.path)
                                launcher.visible = false
                            }
                        }
                    }
                }
                Text { visible: appGrid.count === 0; text: "No results"; color: shell.theme.secondaryText; font.family: shell.theme.fontFamily; Layout.alignment: Qt.AlignHCenter }
            }
        }
    }

    Window {
        id: quickControls
        title: "AR Quick Controls"
        visible: false
        x: Screen.width - width - 22
        y: 74
        width: 390
        height: 540
        color: "transparent"
        flags: Qt.Tool | Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint

        GlassPanel {
            anchors.fill: parent
            anchors.margins: 6
            theme: shell.theme
            strong: true
            radius: shell.theme.radiusLarge
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 14
                RowLayout {
                    Layout.fillWidth: true
                    ColumnLayout {
                        Layout.fillWidth: true
                        Text { text: "Quick controls"; color: shell.theme.text; font.family: shell.theme.fontFamily; font.pixelSize: 21; font.weight: Font.DemiBold }
                        Text { text: ARSystem.networkName.length ? ARSystem.networkName : "Not connected"; color: shell.theme.secondaryText; font.family: shell.theme.fontFamily; font.pixelSize: 12 }
                    }
                    ARButton { theme: shell.theme; text: "Settings"; quiet: true; onClicked: ARSystem.launchCommand("settings") }
                }
                GridLayout {
                    Layout.fillWidth: true
                    columns: 2
                    columnSpacing: 10
                    rowSpacing: 10
                    SettingCard {
                        Layout.fillWidth: true; theme: shell.theme; title: "Wi-Fi"; description: ARSystem.wifiEnabled ? "On" : "Off"; glyph: "⌁"; tint: shell.theme.blue
                        accessory: ToggleSwitch { theme: shell.theme; checked: ARSystem.wifiEnabled; onToggled: ARSystem.wifiEnabled = checked }
                    }
                    SettingCard {
                        Layout.fillWidth: true; theme: shell.theme; title: "Bluetooth"; description: ARSystem.bluetoothEnabled ? "On" : "Off"; glyph: "ᛒ"; tint: shell.theme.accent
                        accessory: ToggleSwitch { theme: shell.theme; checked: ARSystem.bluetoothEnabled; onToggled: ARSystem.bluetoothEnabled = checked }
                    }
                }
                Text { text: "Volume"; color: shell.theme.text; font.family: shell.theme.fontFamily; font.pixelSize: 13; font.weight: Font.DemiBold }
                Slider { Layout.fillWidth: true; from: 0; to: 100; value: ARSystem.volume; onMoved: ARSystem.volume = value }
                Text { text: "Brightness"; color: shell.theme.text; font.family: shell.theme.fontFamily; font.pixelSize: 13; font.weight: Font.DemiBold }
                Slider { Layout.fillWidth: true; from: 1; to: 100; value: ARSystem.brightness; onMoved: ARSystem.brightness = value }
                Rectangle { Layout.fillWidth: true; height: 1; color: shell.theme.divider }
                RowLayout {
                    Layout.fillWidth: true
                    Text { text: "Notifications"; color: shell.theme.text; font.family: shell.theme.fontFamily; font.pixelSize: 17; font.weight: Font.DemiBold; Layout.fillWidth: true }
                    ARButton { theme: shell.theme; text: "Clear"; quiet: true; onClicked: ARNotifications.clear() }
                }
                ListView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    spacing: 8
                    clip: true
                    model: ARNotifications.notifications
                    delegate: GlassPanel {
                        width: ListView.view.width
                        height: 72
                        theme: shell.theme
                        radius: shell.theme.radiusSmall
                        Column {
                            anchors.fill: parent
                            anchors.margins: 12
                            spacing: 3
                            Text { width: parent.width; text: modelData.summary; color: shell.theme.text; font.family: shell.theme.fontFamily; font.pixelSize: 13; font.weight: Font.DemiBold; elide: Text.ElideRight }
                            Text { width: parent.width; text: modelData.body; color: shell.theme.secondaryText; font.family: shell.theme.fontFamily; font.pixelSize: 11; elide: Text.ElideRight }
                        }
                    }
                    Text { anchors.centerIn: parent; visible: parent.count === 0; text: "You’re all caught up"; color: shell.theme.secondaryText; font.family: shell.theme.fontFamily }
                }
                RowLayout {
                    Layout.fillWidth: true
                    Repeater {
                        model: [
                            { text: "Lock", glyph: "⌑", action: function() { ARSystem.lock() } },
                            { text: "Sleep", glyph: "☾", action: function() { ARSystem.suspend() } },
                            { text: "Restart", glyph: "↻", action: function() { ARSystem.restart() } },
                            { text: "Power", glyph: "⏻", action: function() { ARSystem.shutdown() } }
                        ]
                        delegate: ARButton { Layout.fillWidth: true; theme: shell.theme; text: modelData.glyph + " " + modelData.text; onClicked: modelData.action() }
                    }
                }
            }
        }
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: topBar.update()
    }
}

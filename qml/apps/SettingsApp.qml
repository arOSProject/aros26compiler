import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../components"

ARWindow {
    id: root
    appTitle: "Settings"
    appGlyph: "⚙"
    property string page: "Home"
    property var pages: [
        { name: "Home", glyph: "⌂" },
        { name: "Connection", glyph: "⌁" },
        { name: "Connected devices", glyph: "ᛒ" },
        { name: "Sound", glyph: "◖" },
        { name: "Display", glyph: "▣" },
        { name: "Wallpaper", glyph: "▧" },
        { name: "Theme", glyph: "◐" },
        { name: "Notifications", glyph: "◉" },
        { name: "Security & Privacy", glyph: "◇" },
        { name: "Accounts", glyph: "♙" },
        { name: "System Update", glyph: "↻" },
        { name: "About", glyph: "ⓘ" }
    ]

    RowLayout {
        anchors.fill: parent
        spacing: 0
        GlassPanel {
            Layout.preferredWidth: 250
            Layout.fillHeight: true
            theme: root.theme
            radius: 0
            border.width: 0
            color: root.theme.dark ? "#6f2e2844" : "#72ffffff"
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 16
                spacing: 5
                GlassPanel {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 42
                    theme: root.theme
                    radius: 21
                    RowLayout {
                        anchors.fill: parent; anchors.leftMargin: 13; anchors.rightMargin: 13
                        Text { text: "⌕"; color: root.theme.secondaryText; font.pixelSize: 17 }
                        TextField { id: settingsSearch; Layout.fillWidth: true; placeholderText: "Find a setting"; color: root.theme.text; font.family: root.theme.fontFamily; background: Item { } }
                    }
                }
                Item { height: 5 }
                Flickable {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    contentHeight: navColumn.implicitHeight
                    clip: true
                    ColumnLayout {
                        id: navColumn
                        width: parent.width
                        spacing: 4
                        Repeater {
                            model: root.pages
                            delegate: NavItem {
                                Layout.fillWidth: true
                                visible: settingsSearch.text.length === 0 || modelData.name.toLowerCase().indexOf(settingsSearch.text.toLowerCase()) >= 0
                                theme: root.theme
                                text: modelData.name
                                glyph: modelData.glyph
                                selected: root.page === modelData.name
                                onClicked: root.page = modelData.name
                            }
                        }
                    }
                }
                GlassPanel {
                    Layout.fillWidth: true; Layout.preferredHeight: 58; theme: root.theme; radius: root.theme.radiusSmall
                    RowLayout { anchors.fill: parent; anchors.margins: 9
                        ARIcon { theme: root.theme; glyph: "ϟ"; tint: root.theme.accent; width: 38; height: 38 }
                        ColumnLayout { Layout.fillWidth: true; spacing: 1
                            Text { text: ARSystem.displayName; color: root.theme.text; font.family: root.theme.fontFamily; font.pixelSize: 13; font.weight: Font.DemiBold }
                            Text { text: ARSystem.userName; color: root.theme.secondaryText; font.family: root.theme.fontFamily; font.pixelSize: 10 }
                        }
                    }
                }
            }
        }

        Flickable {
            id: contentFlick
            Layout.fillWidth: true
            Layout.fillHeight: true
            contentHeight: contentColumn.implicitHeight + 60
            clip: true
            ScrollBar.vertical: ScrollBar { }

            ColumnLayout {
                id: contentColumn
                width: Math.min(contentFlick.width - 56, 1050)
                x: (contentFlick.width - width) / 2
                y: 28
                spacing: 18

                RowLayout {
                    Layout.fillWidth: true
                    Text { text: root.page; color: root.theme.text; font.family: root.theme.fontFamily; font.pixelSize: 28; font.weight: Font.DemiBold; Layout.fillWidth: true }
                    Text { text: root.page === "Home" ? "Your PC, your way" : "AR OS Settings"; color: root.theme.secondaryText; font.family: root.theme.fontFamily; font.pixelSize: 12 }
                }

                GridLayout {
                    visible: root.page === "Home"
                    Layout.fillWidth: true
                    columns: contentColumn.width > 800 ? 3 : 2
                    columnSpacing: 12; rowSpacing: 12
                    SettingCard {
                        Layout.fillWidth: true; theme: root.theme; title: "Wi-Fi"; description: ARSystem.networkName.length ? ARSystem.networkName : "Not connected"; glyph: "⌁"; tint: root.theme.blue
                        accessory: ToggleSwitch { theme: root.theme; checked: ARSystem.wifiEnabled; onToggled: ARSystem.wifiEnabled = checked }
                    }
                    SettingCard {
                        Layout.fillWidth: true; theme: root.theme; title: "Bluetooth"; description: ARSystem.bluetoothEnabled ? "On" : "Off"; glyph: "ᛒ"; tint: root.theme.accent
                        accessory: ToggleSwitch { theme: root.theme; checked: ARSystem.bluetoothEnabled; onToggled: ARSystem.bluetoothEnabled = checked }
                    }
                    SettingCard { Layout.fillWidth: true; theme: root.theme; title: "AR OS is up to date"; description: "Security and system updates"; glyph: "↻"; tint: root.theme.green; MouseArea { anchors.fill: parent; onClicked: root.page = "System Update" } }
                }

                GlassPanel {
                    visible: root.page === "Home"
                    Layout.fillWidth: true
                    Layout.preferredHeight: 230
                    theme: root.theme
                    radius: root.theme.radiusLarge
                    ColumnLayout {
                        anchors.fill: parent; anchors.margins: 20; spacing: 12
                        Text { text: "Personalize"; color: root.theme.text; font.family: root.theme.fontFamily; font.pixelSize: 17; font.weight: Font.DemiBold }
                        RowLayout {
                            Layout.fillWidth: true; Layout.fillHeight: true; spacing: 12
                            Repeater {
                                model: [
                                    { id: "ribbon", source: "qrc:/qt/qml/AROS/assets/wallpapers/ar-ribbon.svg", label: "Ribbon" },
                                    { id: "night", source: "qrc:/qt/qml/AROS/assets/wallpapers/ar-night.svg", label: "Night" }
                                ]
                                delegate: Rectangle {
                                    Layout.fillWidth: true; Layout.fillHeight: true; radius: 16; clip: true
                                    border.width: ARSystem.wallpaper === modelData.id ? 3 : 1; border.color: ARSystem.wallpaper === modelData.id ? root.theme.accent : root.theme.hairline
                                    Image { anchors.fill: parent; source: modelData.source; fillMode: Image.PreserveAspectCrop }
                                    Rectangle { anchors.left: parent.left; anchors.right: parent.right; anchors.bottom: parent.bottom; height: 38; color: "#7d190d35" }
                                    Text { anchors.left: parent.left; anchors.leftMargin: 12; anchors.verticalCenter: parent.bottom; anchors.verticalCenterOffset: -19; text: modelData.label; color: "white"; font.family: root.theme.fontFamily; font.weight: Font.DemiBold }
                                    MouseArea { anchors.fill: parent; onClicked: ARSystem.wallpaper = modelData.id }
                                }
                            }
                        }
                    }
                }

                GlassPanel {
                    visible: root.page === "Connection" || root.page === "Connected devices"
                    Layout.fillWidth: true; Layout.preferredHeight: 280; theme: root.theme; radius: root.theme.radiusLarge
                    ColumnLayout {
                        anchors.fill: parent; anchors.margins: 22; spacing: 14
                        Text { text: root.page === "Connection" ? "Network" : "Bluetooth devices"; color: root.theme.text; font.family: root.theme.fontFamily; font.pixelSize: 19; font.weight: Font.DemiBold }
                        SettingCard {
                            Layout.fillWidth: true; theme: root.theme; title: root.page === "Connection" ? "Wi-Fi" : "Bluetooth"; description: root.page === "Connection" ? (ARSystem.networkName.length ? "Connected to " + ARSystem.networkName : "Disconnected") : (ARSystem.bluetoothEnabled ? "Ready to connect" : "Off"); glyph: root.page === "Connection" ? "⌁" : "ᛒ"; tint: root.theme.blue
                            accessory: ToggleSwitch { theme: root.theme; checked: root.page === "Connection" ? ARSystem.wifiEnabled : ARSystem.bluetoothEnabled; onToggled: { if (root.page === "Connection") ARSystem.wifiEnabled = checked; else ARSystem.bluetoothEnabled = checked } }
                        }
                        Text { text: root.page === "Connection" ? "Network selection and passwords are managed by NetworkManager. Use the status menu or nm-connection-editor for advanced profiles, VPNs, and enterprise Wi-Fi." : "Device discovery, pairing, and profiles are provided by BlueZ. Connected audio devices are routed through PipeWire."; color: root.theme.secondaryText; font.family: root.theme.fontFamily; font.pixelSize: 13; wrapMode: Text.Wrap; Layout.fillWidth: true }
                        ARButton { theme: root.theme; text: root.page === "Connection" ? "Advanced network settings" : "Pair a device"; primary: true; onClicked: ARSystem.launchCommand(root.page === "Connection" ? "networks" : "bluetooth") }
                        Item { Layout.fillHeight: true }
                    }
                }

                GlassPanel {
                    visible: root.page === "Sound"
                    Layout.fillWidth: true; Layout.preferredHeight: 260; theme: root.theme; radius: root.theme.radiusLarge
                    ColumnLayout { anchors.fill: parent; anchors.margins: 24; spacing: 14
                        Text { text: "Output volume"; color: root.theme.text; font.family: root.theme.fontFamily; font.pixelSize: 17; font.weight: Font.DemiBold }
                        RowLayout { Layout.fillWidth: true
                            Text { text: "◖"; color: root.theme.accent; font.pixelSize: 24 }
                            Slider { Layout.fillWidth: true; from: 0; to: 150; value: ARSystem.volume; onMoved: ARSystem.volume = value }
                            Text { text: Math.round(ARSystem.volume) + "%"; color: root.theme.secondaryText; font.family: root.theme.fontFamily; Layout.preferredWidth: 54 }
                        }
                        Text { text: "AR OS uses PipeWire and WirePlumber for application routing, microphones, Bluetooth audio, and low-latency sound."; color: root.theme.secondaryText; font.family: root.theme.fontFamily; font.pixelSize: 13; wrapMode: Text.Wrap; Layout.fillWidth: true }
                    }
                }

                GlassPanel {
                    visible: root.page === "Display"
                    Layout.fillWidth: true; Layout.preferredHeight: 280; theme: root.theme; radius: root.theme.radiusLarge
                    ColumnLayout { anchors.fill: parent; anchors.margins: 24; spacing: 14
                        Text { text: "Brightness"; color: root.theme.text; font.family: root.theme.fontFamily; font.pixelSize: 17; font.weight: Font.DemiBold }
                        RowLayout { Layout.fillWidth: true
                            Text { text: "☼"; color: root.theme.orange; font.pixelSize: 24 }
                            Slider { Layout.fillWidth: true; from: 1; to: 100; value: ARSystem.brightness; onMoved: ARSystem.brightness = value }
                            Text { text: Math.round(ARSystem.brightness) + "%"; color: root.theme.secondaryText; font.family: root.theme.fontFamily; Layout.preferredWidth: 54 }
                        }
                        Text { text: "KWin handles output layout, fractional scaling, rotation, refresh rate, HDR capability, and hot-plugging through Wayland and KScreen."; color: root.theme.secondaryText; font.family: root.theme.fontFamily; font.pixelSize: 13; wrapMode: Text.Wrap; Layout.fillWidth: true }
                        ARButton { theme: root.theme; text: "Arrange displays"; primary: true; onClicked: ARSystem.launchCommand("displays") }
                    }
                }

                GlassPanel {
                    visible: root.page === "Wallpaper" || root.page === "Theme"
                    Layout.fillWidth: true; Layout.preferredHeight: 330; theme: root.theme; radius: root.theme.radiusLarge
                    ColumnLayout { anchors.fill: parent; anchors.margins: 24; spacing: 16
                        Text { text: root.page === "Wallpaper" ? "Choose a wallpaper" : "Appearance"; color: root.theme.text; font.family: root.theme.fontFamily; font.pixelSize: 18; font.weight: Font.DemiBold }
                        RowLayout { visible: root.page === "Wallpaper"; Layout.fillWidth: true; Layout.fillHeight: true; spacing: 14
                            Repeater { model: [ { id: "ribbon", source: "qrc:/qt/qml/AROS/assets/wallpapers/ar-ribbon.svg", label: "Ribbon" }, { id: "night", source: "qrc:/qt/qml/AROS/assets/wallpapers/ar-night.svg", label: "Night" } ]
                                delegate: Rectangle { Layout.fillWidth: true; Layout.fillHeight: true; radius: 18; clip: true; border.width: ARSystem.wallpaper === modelData.id ? 4 : 1; border.color: ARSystem.wallpaper === modelData.id ? root.theme.accent : root.theme.hairline
                                    Image { anchors.fill: parent; source: modelData.source; fillMode: Image.PreserveAspectCrop }
                                    Text { anchors.left: parent.left; anchors.bottom: parent.bottom; anchors.margins: 14; text: modelData.label; color: "white"; font.family: root.theme.fontFamily; font.pixelSize: 15; font.weight: Font.DemiBold }
                                    MouseArea { anchors.fill: parent; onClicked: ARSystem.wallpaper = modelData.id }
                                }
                            }
                        }
                        RowLayout { visible: root.page === "Theme"; Layout.fillWidth: true; Layout.fillHeight: true; spacing: 16
                            Repeater { model: [ { id: "light", label: "Light", color: "#f7efff" }, { id: "dark", label: "Dark", color: "#241a38" } ]
                                delegate: Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 170; radius: 20; color: modelData.color; border.width: ARSystem.appearance === modelData.id ? 4 : 1; border.color: ARSystem.appearance === modelData.id ? root.theme.accent : root.theme.hairline
                                    Column { anchors.centerIn: parent; spacing: 10
                                        ARIcon { anchors.horizontalCenter: parent.horizontalCenter; theme: root.theme; glyph: modelData.id === "light" ? "☀" : "☾"; tint: root.theme.accent; width: 56; height: 56 }
                                        Text { text: modelData.label; color: modelData.id === "light" ? "#28243a" : "#f8f5ff"; font.family: root.theme.fontFamily; font.pixelSize: 15; font.weight: Font.DemiBold }
                                    }
                                    MouseArea { anchors.fill: parent; onClicked: ARSystem.appearance = modelData.id }
                                }
                            }
                        }
                    }
                }

                GlassPanel {
                    visible: root.page === "Notifications" || root.page === "Security & Privacy" || root.page === "Accounts"
                    Layout.fillWidth: true; Layout.preferredHeight: 270; theme: root.theme; radius: root.theme.radiusLarge
                    ColumnLayout { anchors.fill: parent; anchors.margins: 24; spacing: 12
                        Text { text: root.page; color: root.theme.text; font.family: root.theme.fontFamily; font.pixelSize: 18; font.weight: Font.DemiBold }
                        Text { text: root.page === "Notifications" ? "AR Notifications implements the freedesktop notification service and keeps recent alerts in Quick Controls." : root.page === "Security & Privacy" ? "Screen locking authenticates through PAM. Software installation and protected system changes use polkit rather than running the desktop as root." : "Signed in as " + ARSystem.displayName + " (" + ARSystem.userName + "). User accounts are provided by AccountsService and standard Linux account tools."; color: root.theme.secondaryText; font.family: root.theme.fontFamily; font.pixelSize: 13; wrapMode: Text.Wrap; Layout.fillWidth: true }
                        SettingCard { Layout.fillWidth: true; theme: root.theme; title: root.page === "Notifications" ? "Do not disturb" : root.page === "Security & Privacy" ? "Lock screen" : "Administrator account"; description: root.page === "Notifications" ? "Silence banners while keeping history" : root.page === "Security & Privacy" ? "Require your password after locking" : "Protected actions require authentication"; glyph: root.page === "Notifications" ? "◉" : root.page === "Security & Privacy" ? "⌑" : "♙"; tint: root.theme.accent }
                    }
                }

                GlassPanel {
                    visible: root.page === "System Update"
                    Layout.fillWidth: true; Layout.preferredHeight: 300; theme: root.theme; radius: root.theme.radiusLarge
                    ColumnLayout { anchors.fill: parent; anchors.margins: 24; spacing: 16
                        ARIcon { theme: root.theme; glyph: "↻"; tint: root.theme.green; width: 58; height: 58; Layout.alignment: Qt.AlignHCenter }
                        Text { text: "Keep AR OS secure"; color: root.theme.text; font.family: root.theme.fontFamily; font.pixelSize: 20; font.weight: Font.DemiBold; Layout.alignment: Qt.AlignHCenter }
                        Text { text: "PackageKit delivers Debian and AR OS package updates. Flatpak applications update through their own signed remotes."; color: root.theme.secondaryText; font.family: root.theme.fontFamily; font.pixelSize: 13; wrapMode: Text.Wrap; horizontalAlignment: Text.AlignHCenter; Layout.fillWidth: true }
                        RowLayout { Layout.alignment: Qt.AlignHCenter
                            ARButton { theme: root.theme; text: "Open AR Updater"; primary: true; onClicked: ARSystem.launchCommand("updater") }
                        }
                    }
                }

                GlassPanel {
                    visible: root.page === "About"
                    Layout.fillWidth: true; Layout.preferredHeight: 280; theme: root.theme; radius: root.theme.radiusLarge
                    ColumnLayout { anchors.fill: parent; anchors.margins: 24; spacing: 14
                        ARIcon { theme: root.theme; glyph: "ϟ"; tint: root.theme.accent; width: 62; height: 62; Layout.alignment: Qt.AlignHCenter }
                        Text { text: "AR OS"; color: root.theme.text; font.family: root.theme.fontFamily; font.pixelSize: 24; font.weight: Font.DemiBold; Layout.alignment: Qt.AlignHCenter }
                        Text { text: "A native Wayland Linux desktop inspired by the AR OS 3 concept."; color: root.theme.secondaryText; font.family: root.theme.fontFamily; font.pixelSize: 13; Layout.alignment: Qt.AlignHCenter }
                        ARButton { theme: root.theme; text: "System information"; Layout.alignment: Qt.AlignHCenter; onClicked: ARSystem.launchCommand("about") }
                    }
                }
            }
        }
    }
}

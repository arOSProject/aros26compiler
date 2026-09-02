import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../components"

ARWindow {
    id: root
    appTitle: "AR Software"
    appGlyph: "▣"
    property var catalog: ARSystem.flatpakCatalog()
    property var installed: ARSystem.installedFlatpaks()
    property string category: "Discover"

    RowLayout {
        anchors.fill: parent
        spacing: 0
        GlassPanel {
            Layout.preferredWidth: 230; Layout.fillHeight: true; theme: root.theme; radius: 0; border.width: 0
            color: root.theme.dark ? "#6f2e2844" : "#72ffffff"
            ColumnLayout { anchors.fill: parent; anchors.margins: 16; spacing: 6
                Text { text: "AR Software"; color: root.theme.text; font.family: root.theme.fontFamily; font.pixelSize: 20; font.weight: Font.DemiBold; leftPadding: 10; bottomPadding: 10 }
                Repeater { model: [ {name:"Discover",glyph:"✦"},{name:"Games",glyph:"◆"},{name:"Create",glyph:"✎"},{name:"Media",glyph:"▷"},{name:"Installed",glyph:"↓"},{name:"Updates",glyph:"↻"} ]
                    delegate: NavItem { Layout.fillWidth: true; theme: root.theme; text: modelData.name; glyph: modelData.glyph; selected: root.category === modelData.name; onClicked: { root.category = modelData.name; if (modelData.name === "Updates") ARSystem.launchCommand("updater"); if (modelData.name === "Installed") root.installed = ARSystem.installedFlatpaks() } }
                }
                Item { Layout.fillHeight: true }
                GlassPanel { Layout.fillWidth: true; Layout.preferredHeight: 108; theme: root.theme; radius: root.theme.radius
                    Column { anchors.fill: parent; anchors.margins: 14; spacing: 6
                        Text { text: "Flatpak + native packages"; color: root.theme.text; font.family: root.theme.fontFamily; font.pixelSize: 13; font.weight: Font.DemiBold }
                        Text { width: parent.width; text: "Sandboxed apps come from Flathub. System components stay in signed Debian/AR repositories."; color: root.theme.secondaryText; font.family: root.theme.fontFamily; font.pixelSize: 10; wrapMode: Text.Wrap }
                    }
                }
            }
        }
        Flickable {
            id: scroll
            Layout.fillWidth: true; Layout.fillHeight: true
            contentHeight: page.implicitHeight + 60
            clip: true
            ColumnLayout {
                id: page
                width: Math.min(scroll.width - 64, 1050)
                x: (scroll.width - width) / 2
                y: 30
                spacing: 20
                RowLayout {
                    Layout.fillWidth: true
                    ColumnLayout { Layout.fillWidth: true; spacing: 3
                        Text { text: root.category; color: root.theme.text; font.family: root.theme.fontFamily; font.pixelSize: 28; font.weight: Font.DemiBold }
                        Text { text: root.category === "Installed" ? "Applications installed for your account" : "Useful apps, installed by the real Flatpak service"; color: root.theme.secondaryText; font.family: root.theme.fontFamily; font.pixelSize: 13 }
                    }
                    GlassPanel { Layout.preferredWidth: 320; Layout.preferredHeight: 44; theme: root.theme; radius: 22
                        TextField { id: search; anchors.fill: parent; leftPadding: 16; rightPadding: 16; placeholderText: "Search apps"; color: root.theme.text; font.family: root.theme.fontFamily; background: Item { } }
                    }
                }
                GlassPanel {
                    visible: root.category !== "Installed"
                    Layout.fillWidth: true; Layout.preferredHeight: 190; theme: root.theme; radius: root.theme.radiusLarge; clip: true
                    Rectangle { anchors.fill: parent; gradient: Gradient { orientation: Gradient.Horizontal; GradientStop { position: 0; color: "#8d4cff" } GradientStop { position: 1; color: "#e75bc8" } } }
                    RowLayout { anchors.fill: parent; anchors.margins: 24
                        ColumnLayout { Layout.fillWidth: true
                            Text { text: "Make AR OS yours"; color: "white"; font.family: root.theme.fontFamily; font.pixelSize: 25; font.weight: Font.DemiBold }
                            Text { text: "Games, creative tools, media apps, and Windows compatibility—without making proprietary software part of the base system."; color: "#eaffffff"; font.family: root.theme.fontFamily; font.pixelSize: 13; wrapMode: Text.Wrap; Layout.fillWidth: true }
                        }
                        ARIcon { theme: root.theme; glyph: "ϟ"; tint: "#51ffffff"; width: 110; height: 110 }
                    }
                }
                GridLayout {
                    visible: root.category !== "Installed"
                    Layout.fillWidth: true
                    columns: page.width > 760 ? 3 : 2
                    columnSpacing: 12; rowSpacing: 12
                    Repeater {
                        model: root.catalog
                        delegate: GlassPanel {
                            visible: (root.category === "Discover" || modelData.category === root.category || (root.category === "Games" && modelData.name === "Steam")) && (search.text.length === 0 || modelData.name.toLowerCase().indexOf(search.text.toLowerCase()) >= 0)
                            Layout.fillWidth: true; Layout.preferredHeight: 142; theme: root.theme; radius: root.theme.radius
                            ColumnLayout { anchors.fill: parent; anchors.margins: 15; spacing: 7
                                RowLayout { Layout.fillWidth: true
                                    ARIcon { theme: root.theme; glyph: modelData.name.substring(0,1); tint: modelData.color; width: 46; height: 46 }
                                    ColumnLayout { Layout.fillWidth: true; spacing: 2
                                        Text { text: modelData.name; color: root.theme.text; font.family: root.theme.fontFamily; font.pixelSize: 15; font.weight: Font.DemiBold }
                                        Text { text: modelData.category + " • Flatpak"; color: root.theme.secondaryText; font.family: root.theme.fontFamily; font.pixelSize: 10 }
                                    }
                                }
                                ARButton { Layout.fillWidth: true; theme: root.theme; text: "Install"; primary: true; onClicked: ARSystem.installFlatpak(modelData.id) }
                            }
                        }
                    }
                }
                ColumnLayout {
                    visible: root.category === "Installed"
                    Layout.fillWidth: true
                    spacing: 8
                    Repeater {
                        model: root.installed
                        delegate: SettingCard { Layout.fillWidth: true; theme: root.theme; title: modelData.name; description: modelData.id + (modelData.version ? " • " + modelData.version : ""); glyph: modelData.name.substring(0,1); tint: Qt.hsla((index * .19 + .55) % 1, .65, .55, 1) }
                    }
                    Text { visible: root.installed.length === 0; text: "No Flatpak applications are installed yet."; color: root.theme.secondaryText; font.family: root.theme.fontFamily; font.pixelSize: 14 }
                }
            }
        }
    }
}


import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../components"

ARWindow {
    id: root
    appTitle: "AR Updater"
    appGlyph: "↻"
    width: 900
    height: 660
    property string statusText: "Select Check for updates to query PackageKit."

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 36
        spacing: 20
        ARIcon { theme: root.theme; glyph: "↻"; tint: root.theme.green; width: 78; height: 78; Layout.alignment: Qt.AlignHCenter }
        Text { text: "System Update"; color: root.theme.text; font.family: root.theme.fontFamily; font.pixelSize: 28; font.weight: Font.DemiBold; Layout.alignment: Qt.AlignHCenter }
        Text { text: "Updates are delivered by PackageKit from configured, signed repositories. No update is installed until you approve it."; color: root.theme.secondaryText; font.family: root.theme.fontFamily; font.pixelSize: 13; wrapMode: Text.Wrap; horizontalAlignment: Text.AlignHCenter; Layout.fillWidth: true }
        GlassPanel {
            Layout.fillWidth: true; Layout.fillHeight: true; theme: root.theme; radius: root.theme.radiusLarge
            ScrollView { anchors.fill: parent; anchors.margins: 18
                TextArea { text: root.statusText; color: root.theme.text; font.family: "monospace"; font.pixelSize: 12; readOnly: true; wrapMode: Text.Wrap; background: Item { } }
            }
        }
        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            ARButton { theme: root.theme; text: "Check for updates"; onClicked: root.statusText = ARSystem.checkUpdates() }
            ARButton { theme: root.theme; text: "Install updates"; primary: true; onClicked: ARSystem.installUpdates() }
        }
        Text { text: "Flatpak updates: run “flatpak update” in AR Terminal. Offline update integration is planned for the release channel."; color: root.theme.mutedText; font.family: root.theme.fontFamily; font.pixelSize: 11; Layout.alignment: Qt.AlignHCenter }
    }
}


import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../components"

ARWindow {
    id: root
    appTitle: "About AR OS"
    appGlyph: "ⓘ"
    width: 880
    height: 680
    property var info: ARSystem.systemInfo()

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 34
        spacing: 18
        ARIcon { theme: root.theme; glyph: "ϟ"; tint: root.theme.accent; width: 88; height: 88; Layout.alignment: Qt.AlignHCenter }
        Text { text: "AR OS"; color: root.theme.text; font.family: root.theme.fontFamily; font.pixelSize: 30; font.weight: Font.DemiBold; Layout.alignment: Qt.AlignHCenter }
        Text { text: "Version " + root.info.version + " • Wayland edition"; color: root.theme.secondaryText; font.family: root.theme.fontFamily; font.pixelSize: 13; Layout.alignment: Qt.AlignHCenter }
        GlassPanel {
            Layout.fillWidth: true; Layout.fillHeight: true; theme: root.theme; radius: root.theme.radiusLarge
            GridLayout {
                anchors.fill: parent; anchors.margins: 24; columns: 2; columnSpacing: 28; rowSpacing: 14
                Repeater {
                    model: [
                        { label: "Operating system", value: root.info.base },
                        { label: "Kernel", value: root.info.kernel },
                        { label: "Session", value: root.info.session },
                        { label: "Architecture", value: root.info.architecture },
                        { label: "Processor", value: root.info.cpu },
                        { label: "Memory", value: root.info.memory },
                        { label: "Computer name", value: root.info.host },
                        { label: "Desktop", value: "AR Shell on KWin" }
                    ]
                    delegate: ColumnLayout {
                        Layout.fillWidth: true; spacing: 3
                        Text { text: modelData.label; color: root.theme.mutedText; font.family: root.theme.fontFamily; font.pixelSize: 11; font.weight: Font.DemiBold }
                        Text { Layout.fillWidth: true; text: modelData.value || "Not reported"; color: root.theme.text; font.family: root.theme.fontFamily; font.pixelSize: 13; elide: Text.ElideRight }
                    }
                }
            }
        }
        Text { text: "AR OS is an independent Linux implementation of the AR OS 3 visual concept, built with permission to use the supplied concept references."; color: root.theme.secondaryText; font.family: root.theme.fontFamily; font.pixelSize: 11; wrapMode: Text.Wrap; horizontalAlignment: Text.AlignHCenter; Layout.fillWidth: true }
    }
}


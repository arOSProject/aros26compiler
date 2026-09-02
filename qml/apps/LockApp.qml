import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window
import "../components"

Window {
    id: root
    visible: true
    visibility: Window.FullScreen
    color: "#10062c"
    flags: Qt.Window | Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint
    property var theme: Theme { }

    Image { anchors.fill: parent; source: "qrc:/qt/qml/AROS/assets/wallpapers/ar-night.svg"; fillMode: Image.PreserveAspectCrop }
    Rectangle { anchors.fill: parent; color: "#5208052a" }

    ColumnLayout {
        anchors.fill: parent
        anchors.topMargin: 48
        anchors.bottomMargin: 30
        Text { text: "⌑"; color: "#eaffffff"; font.pixelSize: 22; Layout.alignment: Qt.AlignHCenter }
        Text { text: Qt.formatTime(new Date(), "hh:mm"); color: "white"; font.family: root.theme.fontFamily; font.pixelSize: 38; font.weight: Font.Light; Layout.alignment: Qt.AlignHCenter }
        Text { text: Qt.formatDate(new Date(), "dddd, d MMMM"); color: "#d8ffffff"; font.family: root.theme.fontFamily; font.pixelSize: 14; Layout.alignment: Qt.AlignHCenter }
        Item { Layout.fillHeight: true }
        ARIcon { theme: root.theme; glyph: "ϟ"; tint: root.theme.accent; width: 92; height: 92; Layout.alignment: Qt.AlignHCenter }
        Text { text: ARSystem.displayName; color: "white"; font.family: root.theme.fontFamily; font.pixelSize: 17; font.weight: Font.DemiBold; Layout.alignment: Qt.AlignHCenter }
        GlassPanel {
            Layout.preferredWidth: 330; Layout.preferredHeight: 46; Layout.alignment: Qt.AlignHCenter; theme: root.theme; radius: 23; color: "#5bffffff"
            TextField {
                id: password
                anchors.fill: parent; leftPadding: 18; rightPadding: 48
                placeholderText: "Enter your password"; echoMode: TextInput.Password
                color: "white"; placeholderTextColor: "#baffffff"; font.family: root.theme.fontFamily; background: Item { }
                Keys.onReturnPressed: ARAuth.authenticate(text)
                Component.onCompleted: forceActiveFocus()
            }
            ARButton { anchors.right: parent.right; anchors.rightMargin: 4; anchors.verticalCenter: parent.verticalCenter; width: 38; height: 38; theme: root.theme; text: "→"; primary: true; onClicked: ARAuth.authenticate(password.text) }
        }
        Text { text: ARAuth.error; visible: text.length > 0; color: "#ffb4c0"; font.family: root.theme.fontFamily; font.pixelSize: 12; Layout.alignment: Qt.AlignHCenter }
        Item { Layout.fillHeight: true }
        RowLayout {
            Layout.alignment: Qt.AlignHCenter; spacing: 10
            ARButton { theme: root.theme; text: "☾ Sleep"; onClicked: ARSystem.suspend() }
            ARButton { theme: root.theme; text: "↻ Restart"; onClicked: ARSystem.restart() }
            ARButton { theme: root.theme; text: "⏻ Power off"; onClicked: ARSystem.shutdown() }
        }
    }
    Connections { target: ARAuth; function onUnlocked() { root.close() } }
    Timer { interval: 1000; running: true; repeat: true; onTriggered: root.update() }
}


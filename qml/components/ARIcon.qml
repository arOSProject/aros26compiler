import QtQuick

Rectangle {
    id: root
    property var theme
    property string glyph: "◆"
    property color tint: theme ? theme.accent : "#8d4cff"
    property string label: ""
    property bool round: true
    radius: round ? width / 2 : (theme ? theme.radiusSmall : 12)
    color: tint
    border.width: 1
    border.color: "#54ffffff"

    Rectangle {
        anchors.fill: parent
        radius: parent.radius
        gradient: Gradient {
            GradientStop { position: 0; color: "#52ffffff" }
            GradientStop { position: 0.6; color: "#04ffffff" }
            GradientStop { position: 1; color: "#22000000" }
        }
    }
    Text {
        anchors.centerIn: parent
        text: root.glyph
        color: "white"
        font.pixelSize: Math.max(13, root.width * 0.42)
        font.weight: Font.DemiBold
        font.family: root.theme ? root.theme.fontFamily : "sans-serif"
    }
}


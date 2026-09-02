import QtQuick

Rectangle {
    id: root
    property var theme
    property string text: ""
    property string glyph: "•"
    property bool selected: false
    signal clicked
    implicitHeight: 44
    radius: theme ? theme.radiusSmall : 12
    color: selected ? (theme ? theme.softSurface : "#80ffffff") : mouse.containsMouse ? "#42ffffff" : "transparent"
    border.width: selected ? 1 : 0
    border.color: theme ? theme.hairline : "#90ffffff"

    Text {
        anchors.left: parent.left
        anchors.leftMargin: 14
        anchors.verticalCenter: parent.verticalCenter
        text: root.glyph
        color: root.selected ? root.theme.accent : root.theme.secondaryText
        font.pixelSize: 17
    }
    Text {
        anchors.left: parent.left
        anchors.leftMargin: 44
        anchors.verticalCenter: parent.verticalCenter
        text: root.text
        color: root.theme.text
        font.family: root.theme.fontFamily
        font.pixelSize: 14
        font.weight: root.selected ? Font.DemiBold : Font.Normal
    }
    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        onClicked: root.clicked()
    }
}


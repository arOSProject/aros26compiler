import QtQuick

Rectangle {
    id: root
    property var theme
    property bool strong: false
    property real glassOpacity: 1.0
    radius: theme ? theme.radius : 18
    color: theme ? (strong ? theme.strongSurface : theme.surface) : "#ccffffff"
    opacity: glassOpacity
    border.width: 1
    border.color: theme ? theme.hairline : "#90ffffff"
    antialiasing: true

    Rectangle {
        anchors.fill: parent
        anchors.margins: 1
        radius: Math.max(0, parent.radius - 1)
        color: "transparent"
        border.width: 1
        border.color: "#24ffffff"
        visible: parent.radius > 0
    }
}


import QtQuick

GlassPanel {
    id: root
    property string title: ""
    property string description: ""
    property string glyph: "◆"
    property color tint: theme ? theme.accent : "#8d4cff"
    property alias accessory: accessory.data
    implicitHeight: 86
    strong: false

    ARIcon {
        id: icon
        theme: root.theme
        glyph: root.glyph
        tint: root.tint
        width: 44
        height: 44
        anchors.left: parent.left
        anchors.leftMargin: 16
        anchors.verticalCenter: parent.verticalCenter
    }
    Column {
        anchors.left: icon.right
        anchors.leftMargin: 14
        anchors.right: accessory.left
        anchors.rightMargin: 12
        anchors.verticalCenter: parent.verticalCenter
        spacing: 4
        Text {
            text: root.title
            color: root.theme.text
            font.family: root.theme.fontFamily
            font.pixelSize: 15
            font.weight: Font.DemiBold
            elide: Text.ElideRight
            width: parent.width
        }
        Text {
            text: root.description
            color: root.theme.secondaryText
            font.family: root.theme.fontFamily
            font.pixelSize: 12
            elide: Text.ElideRight
            width: parent.width
        }
    }
    Item {
        id: accessory
        width: childrenRect.width
        height: Math.max(44, childrenRect.height)
        anchors.right: parent.right
        anchors.rightMargin: 16
        anchors.verticalCenter: parent.verticalCenter
    }
}


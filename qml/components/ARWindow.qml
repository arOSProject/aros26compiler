import QtQuick
import QtQuick.Controls

Window {
    id: root
    default property alias contentData: body.data
    property string appTitle: "AR OS"
    property string appGlyph: "◆"
    property alias bodyItem: body
    property var theme: Theme { }
    width: 1180
    height: 760
    minimumWidth: 760
    minimumHeight: 520
    visible: true
    color: "transparent"
    flags: Qt.Window | Qt.FramelessWindowHint

    Rectangle {
        id: shadow
        anchors.fill: panel
        anchors.margins: -12
        radius: panel.radius + 12
        color: "#230b062c"
        z: -2
    }
    GlassPanel {
        id: panel
        anchors.fill: parent
        anchors.margins: 1
        radius: root.theme.radiusLarge
        theme: root.theme
        strong: true
        clip: true

        Rectangle {
            id: chrome
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            height: 54
            color: root.theme.dark ? "#552d2549" : "#72ffffff"
            Rectangle { anchors.bottom: parent.bottom; width: parent.width; height: 1; color: root.theme.divider }

            ARIcon {
                theme: root.theme
                glyph: root.appGlyph
                tint: root.theme.accent
                width: 30
                height: 30
                anchors.left: parent.left
                anchors.leftMargin: 14
                anchors.verticalCenter: parent.verticalCenter
            }
            Text {
                text: root.appTitle
                color: root.theme.text
                font.family: root.theme.fontFamily
                font.pixelSize: 14
                font.weight: Font.DemiBold
                anchors.left: parent.left
                anchors.leftMargin: 54
                anchors.verticalCenter: parent.verticalCenter
            }
            Row {
                anchors.right: parent.right
                anchors.rightMargin: 10
                anchors.verticalCenter: parent.verticalCenter
                spacing: 5
                Repeater {
                    model: ["−", "□", "×"]
                    delegate: Rectangle {
                        width: 36; height: 32; radius: 10
                        color: buttonMouse.containsMouse ? (index === 2 ? "#e95a70" : "#52ffffff") : "transparent"
                        Text { anchors.centerIn: parent; text: modelData; color: index === 2 && buttonMouse.containsMouse ? "white" : root.theme.text; font.pixelSize: 16 }
                        MouseArea {
                            id: buttonMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: {
                                if (index === 0) root.showMinimized()
                                else if (index === 1) root.visibility === Window.Maximized ? root.showNormal() : root.showMaximized()
                                else root.close()
                            }
                        }
                    }
                }
            }
            MouseArea {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.rightMargin: 132
                onPressed: root.startSystemMove()
                onDoubleClicked: root.visibility === Window.Maximized ? root.showNormal() : root.showMaximized()
            }
        }
        Item {
            id: body
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: chrome.bottom
            anchors.bottom: parent.bottom
        }
    }
}


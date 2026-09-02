import QtQuick
import QtQuick.Controls

Switch {
    id: control
    property var theme
    implicitWidth: 52
    implicitHeight: 30
    indicator: Rectangle {
        implicitWidth: 52
        implicitHeight: 30
        radius: 15
        color: control.checked ? (control.theme ? control.theme.accent : "#8d4cff") : "#78928aa0"
        border.width: 1
        border.color: "#5effffff"
        Rectangle {
            width: 24
            height: 24
            radius: 12
            x: control.checked ? parent.width - width - 3 : 3
            y: 3
            color: "white"
            Behavior on x { NumberAnimation { duration: 170; easing.type: Easing.OutCubic } }
        }
        Behavior on color { ColorAnimation { duration: 140 } }
    }
    contentItem: Item { }
}


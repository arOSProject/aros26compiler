import QtQuick
import QtQuick.Controls

Button {
    id: control
    property var theme
    property bool primary: false
    property bool quiet: false
    implicitHeight: 42
    implicitWidth: Math.max(96, label.implicitWidth + 34)
    hoverEnabled: true

    contentItem: Text {
        id: label
        text: control.text
        color: control.primary ? "white" : (control.theme ? control.theme.text : "#28243a")
        font.family: control.theme ? control.theme.fontFamily : "sans-serif"
        font.pixelSize: 14
        font.weight: Font.DemiBold
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }

    background: Rectangle {
        radius: control.theme ? control.theme.radiusSmall : 12
        color: control.quiet ? "transparent"
                             : control.primary ? (control.down ? "#6f35dd" : control.hovered ? "#9c63ff" : "#8d4cff")
                                               : control.down ? "#50ffffff" : control.hovered ? "#d9ffffff" : "#a8ffffff"
        border.width: control.quiet ? 0 : 1
        border.color: control.primary ? "#62ffffff" : "#78ffffff"
        scale: control.down ? 0.97 : 1
        Behavior on scale { NumberAnimation { duration: 90 } }
        Behavior on color { ColorAnimation { duration: 120 } }
    }
}


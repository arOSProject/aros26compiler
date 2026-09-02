import QtQuick 2.15
import QtQuick.Controls 2.15
import SddmComponents 2.0

Rectangle {
    id: root
    width: 1920
    height: 1080
    color: "#10062c"
    property int selectedUser: userModel.lastIndex

    Image { anchors.fill: parent; source: config.background; fillMode: Image.PreserveAspectCrop }
    Rectangle { anchors.fill: parent; color: "#4b08052a" }

    Column {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 54
        spacing: 5
        Text { anchors.horizontalCenter: parent.horizontalCenter; text: Qt.formatTime(new Date(), "hh:mm"); color: "white"; font.family: config.font; font.pixelSize: 38; font.weight: Font.Light }
        Text { anchors.horizontalCenter: parent.horizontalCenter; text: Qt.formatDate(new Date(), "dddd, d MMMM"); color: "#d7ffffff"; font.family: config.font; font.pixelSize: 14 }
    }

    Column {
        anchors.centerIn: parent
        spacing: 12
        Image { anchors.horizontalCenter: parent.horizontalCenter; source: config.logo; width: 96; height: 96; sourceSize.width: 192; sourceSize.height: 192 }
        Text { anchors.horizontalCenter: parent.horizontalCenter; text: userModel.data(userModel.index(root.selectedUser, 0), Qt.DisplayRole); color: "white"; font.family: config.font; font.pixelSize: 17; font.weight: Font.DemiBold }
        Rectangle {
            width: 330; height: 48; radius: 24; color: "#48ffffff"; border.width: 1; border.color: "#5fffffff"
            TextField {
                id: password
                anchors.fill: parent; leftPadding: 18; rightPadding: 50
                placeholderText: "Enter your password"; echoMode: TextInput.Password
                color: "white"; placeholderTextColor: "#baffffff"; background: Item { }
                Keys.onReturnPressed: sddm.login(root.selectedUser, text, session.index)
            }
            Rectangle {
                anchors.right: parent.right; anchors.rightMargin: 5; anchors.verticalCenter: parent.verticalCenter
                width: 38; height: 38; radius: 19; color: "#8d4cff"
                Text { anchors.centerIn: parent; text: "→"; color: "white"; font.pixelSize: 18 }
                MouseArea { anchors.fill: parent; onClicked: sddm.login(root.selectedUser, password.text, session.index) }
            }
        }
        Text { anchors.horizontalCenter: parent.horizontalCenter; visible: sddm.loginFailed; text: "That password was not accepted."; color: "#ffbdc8"; font.family: config.font; font.pixelSize: 12 }
    }

    Row {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 30
        spacing: 10
        Repeater {
            model: [ {label:"Sleep", action:"suspend"}, {label:"Restart", action:"reboot"}, {label:"Power off", action:"powerOff"} ]
            delegate: Rectangle {
                width: 112; height: 40; radius: 20; color: "#34ffffff"; border.width: 1; border.color: "#3fffffff"
                Text { anchors.centerIn: parent; text: modelData.label; color: "white"; font.family: config.font; font.pixelSize: 12 }
                MouseArea { anchors.fill: parent; onClicked: { if (modelData.action === "suspend") sddm.suspend(); else if (modelData.action === "reboot") sddm.reboot(); else sddm.powerOff() } }
            }
        }
    }

    ComboBox { id: session; model: sessionModel; textRole: "name"; currentIndex: sessionModel.lastIndex; visible: false }
    Timer { interval: 1000; running: true; repeat: true; onTriggered: root.update() }
    Component.onCompleted: password.forceActiveFocus()
}


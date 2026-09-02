import QtQuick 2.15

Presentation {
    id: presentation
    Timer { interval: 6000; running: true; repeat: true; onTriggered: presentation.goToNextSlide() }
    Slide {
        Image { anchors.fill: parent; source: "welcome.svg"; fillMode: Image.PreserveAspectCrop }
        Text { anchors.centerIn: parent; text: "Welcome to AR OS"; color: "white"; font.pixelSize: 34; font.bold: true }
    }
    Slide {
        Image { anchors.fill: parent; source: "welcome.svg"; fillMode: Image.PreserveAspectCrop }
        Text { anchors.centerIn: parent; text: "Native Wayland. Your files. Your PC."; color: "white"; font.pixelSize: 28; font.bold: true }
    }
    Slide {
        Image { anchors.fill: parent; source: "welcome.svg"; fillMode: Image.PreserveAspectCrop }
        Text { anchors.centerIn: parent; text: "Almost ready"; color: "white"; font.pixelSize: 34; font.bold: true }
    }
}


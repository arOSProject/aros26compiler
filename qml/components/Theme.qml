import QtQuick

QtObject {
    readonly property bool dark: ARSystem.appearance === "dark"
    readonly property color text: dark ? "#f8f5ff" : "#28243a"
    readonly property color secondaryText: dark ? "#c8c0d8" : "#6d647e"
    readonly property color mutedText: dark ? "#9d94b1" : "#8b8298"
    readonly property color accent: "#8d4cff"
    readonly property color accent2: "#ff59c7"
    readonly property color blue: "#3c8cff"
    readonly property color cyan: "#28c5df"
    readonly property color green: "#38c990"
    readonly property color orange: "#ff9d3f"
    readonly property color red: "#ff5d77"
    readonly property color surface: dark ? "#c71a1630" : "#c9ffffff"
    readonly property color strongSurface: dark ? "#ec1b1730" : "#edffffff"
    readonly property color softSurface: dark ? "#8f40385e" : "#75ffffff"
    readonly property color hairline: dark ? "#46ffffff" : "#8ffffffF"
    readonly property color divider: dark ? "#2cffffff" : "#1c342752"
    readonly property color scrim: "#470f0822"
    readonly property int radiusSmall: 12
    readonly property int radius: 18
    readonly property int radiusLarge: 28
    readonly property int radiusPill: 999
    readonly property int space1: 6
    readonly property int space2: 10
    readonly property int space3: 16
    readonly property int space4: 24
    readonly property int space5: 32
    readonly property int animationFast: 150
    readonly property int animationNormal: 260
    readonly property string fontFamily: "Inter, Noto Sans, sans-serif"
}


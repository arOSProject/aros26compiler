import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window
import "../components"

Window {
    id: root
    visible: true
    visibility: Window.FullScreen
    color: "#d8b9ff"
    flags: Qt.Window | Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint
    property var theme: Theme { }
    property int step: 0
    property var steps: ["Welcome", "Region", "Keyboard", "Account", "Appearance", "Location", "Privacy", "Finish"]
    property var values: ({ locale: "en_US.UTF-8", timezone: "America/Chicago", keyboard: "us", fullName: ARSystem.displayName, appearance: ARSystem.appearance, wallpaper: ARSystem.wallpaper, location: false, diagnostics: false, automaticUpdates: true })
    function setValue(key, value) {
        var next = {}
        for (var item in values) next[item] = values[item]
        next[key] = value
        values = next
    }

    Image { anchors.fill: parent; source: "qrc:/qt/qml/AROS/assets/wallpapers/ar-ribbon.svg"; fillMode: Image.PreserveAspectCrop }
    Rectangle { anchors.fill: parent; color: "#36ffffff" }

    GlassPanel {
        id: panel
        theme: root.theme
        strong: true
        width: Math.min(parent.width - 80, 1120)
        height: Math.min(parent.height - 80, 760)
        anchors.centerIn: parent
        radius: root.theme.radiusLarge

        RowLayout {
            anchors.fill: parent
            spacing: 0
            GlassPanel {
                Layout.preferredWidth: 250; Layout.fillHeight: true; theme: root.theme; radius: root.theme.radiusLarge; border.width: 0
                color: "#5dffffff"
                ColumnLayout {
                    anchors.fill: parent; anchors.margins: 18; spacing: 5
                    RowLayout { Layout.fillWidth: true; Layout.bottomMargin: 18
                        ARIcon { theme: root.theme; glyph: "ϟ"; tint: root.theme.accent; width: 38; height: 38 }
                        Text { text: "AR Setup"; color: root.theme.text; font.family: root.theme.fontFamily; font.pixelSize: 17; font.weight: Font.DemiBold }
                    }
                    Repeater {
                        model: root.steps
                        delegate: NavItem { Layout.fillWidth: true; theme: root.theme; text: modelData; glyph: index < root.step ? "✓" : index === root.step ? "◆" : "○"; selected: index === root.step }
                    }
                    Item { Layout.fillHeight: true }
                    Text { text: "Your choices are stored locally. Protected system changes use polkit."; color: root.theme.mutedText; font.family: root.theme.fontFamily; font.pixelSize: 10; wrapMode: Text.Wrap; Layout.fillWidth: true }
                }
            }

            ColumnLayout {
                Layout.fillWidth: true; Layout.fillHeight: true
                Layout.leftMargin: 42; Layout.rightMargin: 42; Layout.topMargin: 36; Layout.bottomMargin: 28
                spacing: 14

                Loader {
                    id: pageLoader
                    Layout.fillWidth: true; Layout.fillHeight: true
                    sourceComponent: root.step === 0 ? welcomePage : root.step === 1 ? regionPage : root.step === 2 ? keyboardPage : root.step === 3 ? accountPage : root.step === 4 ? appearancePage : root.step === 5 ? locationPage : root.step === 6 ? privacyPage : finishPage
                }
                RowLayout {
                    Layout.fillWidth: true
                    ARButton { visible: root.step > 0 && root.step < root.steps.length - 1; theme: root.theme; text: "← Back"; onClicked: root.step-- }
                    Item { Layout.fillWidth: true }
                    ARButton {
                        visible: root.step < root.steps.length - 1
                        theme: root.theme; text: root.step === 0 ? "Start" : "Next →"; primary: true
                        onClicked: root.step++
                    }
                    ARButton {
                        visible: root.step === root.steps.length - 1
                        theme: root.theme; text: "Use AR OS"; primary: true
                        onClicked: { if (ARSystem.applyOobe(root.values)) root.close() }
                    }
                }
            }
        }
    }

    Component {
        id: welcomePage
        ColumnLayout {
            spacing: 18
            Item { Layout.fillHeight: true }
            ARIcon { theme: root.theme; glyph: "ϟ"; tint: root.theme.accent; width: 90; height: 90; Layout.alignment: Qt.AlignHCenter }
            Text { text: "Welcome to AR OS"; color: root.theme.text; font.family: root.theme.fontFamily; font.pixelSize: 32; font.weight: Font.DemiBold; Layout.alignment: Qt.AlignHCenter }
            Text { text: "A few real system choices are left before your desktop is ready. Setup will configure your locale, appearance, privacy preferences, and update policy."; color: root.theme.secondaryText; font.family: root.theme.fontFamily; font.pixelSize: 14; wrapMode: Text.Wrap; horizontalAlignment: Text.AlignHCenter; Layout.preferredWidth: 620; Layout.alignment: Qt.AlignHCenter }
            Item { Layout.fillHeight: true }
        }
    }
    Component {
        id: regionPage
        ColumnLayout {
            spacing: 16
            Text { text: "Region and language"; color: root.theme.text; font.family: root.theme.fontFamily; font.pixelSize: 28; font.weight: Font.DemiBold }
            Text { text: "Choose the language and formats applications should use."; color: root.theme.secondaryText; font.family: root.theme.fontFamily; font.pixelSize: 13 }
            SettingCard { Layout.fillWidth: true; theme: root.theme; title: "Display language"; description: "Used by AR OS and applications"; glyph: "◎"; tint: root.theme.blue
                accessory: ComboBox { model: ["English (United States)", "English (United Kingdom)", "Español", "Français", "Deutsch"]; onActivated: root.setValue("locale", currentIndex === 1 ? "en_GB.UTF-8" : currentIndex === 2 ? "es_ES.UTF-8" : currentIndex === 3 ? "fr_FR.UTF-8" : currentIndex === 4 ? "de_DE.UTF-8" : "en_US.UTF-8") }
            }
            SettingCard { Layout.fillWidth: true; theme: root.theme; title: "Formats"; description: "Dates, numbers, measurements"; glyph: "◷"; tint: root.theme.accent; accessory: Text { text: root.values.locale; color: root.theme.secondaryText; font.family: root.theme.fontFamily } }
            Item { Layout.fillHeight: true }
        }
    }
    Component {
        id: keyboardPage
        ColumnLayout {
            spacing: 16
            Text { text: "Keyboard"; color: root.theme.text; font.family: root.theme.fontFamily; font.pixelSize: 28; font.weight: Font.DemiBold }
            Text { text: "Select the layout that matches your physical keyboard."; color: root.theme.secondaryText; font.family: root.theme.fontFamily; font.pixelSize: 13 }
            SettingCard { Layout.fillWidth: true; theme: root.theme; title: "Keyboard layout"; description: "Applied through system locale settings"; glyph: "⌨"; tint: root.theme.cyan
                accessory: ComboBox { model: ["English (US)", "English (UK)", "Spanish", "French", "German"]; onActivated: root.setValue("keyboard", currentIndex === 1 ? "gb" : currentIndex === 2 ? "es" : currentIndex === 3 ? "fr" : currentIndex === 4 ? "de" : "us") }
            }
            TextField { Layout.fillWidth: true; placeholderText: "Type here to test your keyboard"; color: root.theme.text; font.family: root.theme.fontFamily }
            Item { Layout.fillHeight: true }
        }
    }
    Component {
        id: accountPage
        ColumnLayout {
            spacing: 16
            Text { text: "Your account"; color: root.theme.text; font.family: root.theme.fontFamily; font.pixelSize: 28; font.weight: Font.DemiBold }
            Text { text: "Your login name and password were created by the installer. You can choose the name AR OS displays."; color: root.theme.secondaryText; font.family: root.theme.fontFamily; font.pixelSize: 13; wrapMode: Text.Wrap; Layout.fillWidth: true }
            RowLayout { Layout.fillWidth: true
                ARIcon { theme: root.theme; glyph: "ϟ"; tint: root.theme.accent; width: 76; height: 76 }
                ColumnLayout { Layout.fillWidth: true
                    TextField { Layout.fillWidth: true; text: root.values.fullName; placeholderText: "Full name"; color: root.theme.text; font.family: root.theme.fontFamily; onTextEdited: root.setValue("fullName", text) }
                    Text { text: "Username: " + ARSystem.userName; color: root.theme.secondaryText; font.family: root.theme.fontFamily; font.pixelSize: 12 }
                }
            }
            SettingCard { Layout.fillWidth: true; theme: root.theme; title: "Administrator access"; description: "Protected changes ask for your password through polkit"; glyph: "◇"; tint: root.theme.green }
            Item { Layout.fillHeight: true }
        }
    }
    Component {
        id: appearancePage
        ColumnLayout {
            spacing: 16
            Text { text: "Make it yours"; color: root.theme.text; font.family: root.theme.fontFamily; font.pixelSize: 28; font.weight: Font.DemiBold }
            Text { text: "Choose an appearance and wallpaper. You can change both later in Settings."; color: root.theme.secondaryText; font.family: root.theme.fontFamily; font.pixelSize: 13 }
            RowLayout { Layout.fillWidth: true; Layout.preferredHeight: 190; spacing: 14
                Repeater { model: [ { id:"ribbon", source:"qrc:/qt/qml/AROS/assets/wallpapers/ar-ribbon.svg", label:"Ribbon" }, { id:"night", source:"qrc:/qt/qml/AROS/assets/wallpapers/ar-night.svg", label:"Night" } ]
                    delegate: Rectangle { Layout.fillWidth: true; Layout.fillHeight: true; radius: 18; clip: true; border.width: root.values.wallpaper === modelData.id ? 4 : 1; border.color: root.values.wallpaper === modelData.id ? root.theme.accent : root.theme.hairline
                        Image { anchors.fill: parent; source: modelData.source; fillMode: Image.PreserveAspectCrop }
                        Text { anchors.left: parent.left; anchors.bottom: parent.bottom; anchors.margins: 12; text: modelData.label; color: "white"; font.family: root.theme.fontFamily; font.weight: Font.DemiBold }
                        MouseArea { anchors.fill: parent; onClicked: root.setValue("wallpaper", modelData.id) }
                    }
                }
            }
            RowLayout { Layout.fillWidth: true
                ARButton { Layout.fillWidth: true; theme: root.theme; text: "☀ Light"; primary: root.values.appearance === "light"; onClicked: root.setValue("appearance", "light") }
                ARButton { Layout.fillWidth: true; theme: root.theme; text: "☾ Dark"; primary: root.values.appearance === "dark"; onClicked: root.setValue("appearance", "dark") }
            }
            Item { Layout.fillHeight: true }
        }
    }
    Component {
        id: locationPage
        ColumnLayout {
            spacing: 16
            Text { text: "Location and time zone"; color: root.theme.text; font.family: root.theme.fontFamily; font.pixelSize: 28; font.weight: Font.DemiBold }
            Text { text: "Location access is opt-in. Your time zone can be set without sharing live location with applications."; color: root.theme.secondaryText; font.family: root.theme.fontFamily; font.pixelSize: 13; wrapMode: Text.Wrap; Layout.fillWidth: true }
            SettingCard { Layout.fillWidth: true; theme: root.theme; title: "Location services"; description: root.values.location ? "Applications may request access" : "Off"; glyph: "⌖"; tint: root.theme.red; accessory: ToggleSwitch { theme: root.theme; checked: root.values.location; onToggled: root.setValue("location", checked) } }
            SettingCard { Layout.fillWidth: true; theme: root.theme; title: "Time zone"; description: "Applied by systemd-timedated"; glyph: "◷"; tint: root.theme.blue
                accessory: ComboBox { model: ["America/Chicago", "America/New_York", "America/Los_Angeles", "Europe/London", "Europe/Paris", "Asia/Tokyo"]; onActivated: root.setValue("timezone", currentText) }
            }
            Item { Layout.fillHeight: true }
        }
    }
    Component {
        id: privacyPage
        ColumnLayout {
            spacing: 14
            Text { text: "Privacy and security"; color: root.theme.text; font.family: root.theme.fontFamily; font.pixelSize: 28; font.weight: Font.DemiBold }
            Text { text: "AR OS does not require a cloud account. Choose what the local system may do automatically."; color: root.theme.secondaryText; font.family: root.theme.fontFamily; font.pixelSize: 13; wrapMode: Text.Wrap; Layout.fillWidth: true }
            SettingCard { Layout.fillWidth: true; theme: root.theme; title: "Automatic security updates"; description: "Recommended; delivered from signed repositories"; glyph: "◇"; tint: root.theme.green; accessory: ToggleSwitch { theme: root.theme; checked: root.values.automaticUpdates; onToggled: root.setValue("automaticUpdates", checked) } }
            SettingCard { Layout.fillWidth: true; theme: root.theme; title: "Crash diagnostics"; description: "Store local crash reports for troubleshooting"; glyph: "!"; tint: root.theme.orange; accessory: ToggleSwitch { theme: root.theme; checked: root.values.diagnostics; onToggled: root.setValue("diagnostics", checked) } }
            Text { text: "No telemetry is uploaded by this implementation. Future network reporting must remain opt-in and documented."; color: root.theme.mutedText; font.family: root.theme.fontFamily; font.pixelSize: 11; wrapMode: Text.Wrap; Layout.fillWidth: true }
            Item { Layout.fillHeight: true }
        }
    }
    Component {
        id: finishPage
        ColumnLayout {
            spacing: 18
            Item { Layout.fillHeight: true }
            ARIcon { theme: root.theme; glyph: "✓"; tint: root.theme.green; width: 90; height: 90; Layout.alignment: Qt.AlignHCenter }
            Text { text: "Ready!"; color: root.theme.text; font.family: root.theme.fontFamily; font.pixelSize: 32; font.weight: Font.DemiBold; Layout.alignment: Qt.AlignHCenter }
            Text { text: "Your desktop is configured. AR Setup can be run again from AR Launcher, and every setting here remains available in Settings."; color: root.theme.secondaryText; font.family: root.theme.fontFamily; font.pixelSize: 14; wrapMode: Text.Wrap; horizontalAlignment: Text.AlignHCenter; Layout.preferredWidth: 600; Layout.alignment: Qt.AlignHCenter }
            Item { Layout.fillHeight: true }
        }
    }
}

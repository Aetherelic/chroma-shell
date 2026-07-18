import QtQuick
import QtQuick.Layouts
import "../components"

Flickable {
    id: page

    required property var shell
    required property var settings

    contentWidth: width
    contentHeight: content.implicitHeight + 28
    clip: true

    ColumnLayout {
        id: content
        width: page.width
        spacing: 16

        PageHeader {
            shell: page.shell
            index: "09"
            title: "Credits"
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 188
            color: shell.uiPalette[0]
            radius: shell.cardRadius
            border.width: shell.borderWidth
            border.color: shell.border
            clip: true

            RowLayout {
                anchors {
                    fill: parent
                    margins: 26
                }
                spacing: 22

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 7

                    Text {
                        text: "CHROMA"
                        color: shell.ink
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: Math.round(34 * shell.fontScale)
                        font.weight: Font.Black
                        font.letterSpacing: 2
                    }

                    Text {
                        text: "DESIGNED AND DEVELOPED BY"
                        color: shell.ink
                        opacity: 0.68
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: Math.round(8 * shell.fontScale)
                        font.weight: Font.Black
                        font.letterSpacing: 1.4
                    }

                    Text {
                        text: "AETHERELIC"
                        color: shell.ink
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: Math.round(20 * shell.fontScale)
                        font.weight: Font.Black
                        font.letterSpacing: 1.2
                    }

                    Text {
                        text: "GITHUB  //  @AETHERELIC"
                        color: shell.ink
                        opacity: 0.78
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: Math.round(9 * shell.fontScale)
                        font.weight: Font.Black
                        font.letterSpacing: 1
                    }
                }

                Column {
                    Layout.alignment: Qt.AlignVCenter
                    spacing: 7

                    Repeater {
                        model: shell.spectrumPalette
                        Rectangle {
                            required property var modelData
                            width: 94
                            height: 10
                            color: modelData
                            radius: shell.microRadius
                        }
                    }
                }
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: Qt.openUrlExternally("https://github.com/Aetherelic")
            }
        }

        SettingsCard {
            shell: page.shell
            Layout.fillWidth: true
            title: "Core stack"
            accent: shell.uiPalette[4]

            InfoRow { shell: page.shell; Layout.fillWidth: true; label: "Quickshell"; value: "QML shell runtime and native service integrations" }
            InfoRow { shell: page.shell; Layout.fillWidth: true; label: "Hyprland"; value: "Wayland compositor and workspace engine" }
            InfoRow { shell: page.shell; Layout.fillWidth: true; label: "Qt Quick"; value: "Declarative interface and animation framework" }
            InfoRow { shell: page.shell; Layout.fillWidth: true; label: "NixOS"; value: "Declarative operating system and package graph" }
            InfoRow { shell: page.shell; Layout.fillWidth: true; label: "CAVA"; value: "Real-time audio spectrum data" }
            InfoRow { shell: page.shell; Layout.fillWidth: true; label: "AWWW / SWWW"; value: "Animated wallpaper daemon" }
            InfoRow { shell: page.shell; Layout.fillWidth: true; label: "Rofi"; value: "Wallpaper selection grid" }
        }

        SettingsCard {
            shell: page.shell
            Layout.fillWidth: true
            title: "Palette acknowledgements"
            accent: shell.uiPalette[3]

            InfoRow { shell: page.shell; Layout.fillWidth: true; label: "Catppuccin"; value: "Mocha palette" }
            InfoRow { shell: page.shell; Layout.fillWidth: true; label: "Gruvbox"; value: "Dark palette" }
            InfoRow { shell: page.shell; Layout.fillWidth: true; label: "Tokyo Night"; value: "Night palette" }
            InfoRow { shell: page.shell; Layout.fillWidth: true; label: "Nord"; value: "Polar Night and Aurora palette" }
            InfoRow { shell: page.shell; Layout.fillWidth: true; label: "Rosé Pine"; value: "Main palette" }
            InfoRow { shell: page.shell; Layout.fillWidth: true; label: "Kanagawa"; value: "Wave palette" }
            InfoRow { shell: page.shell; Layout.fillWidth: true; label: "Dracula"; value: "Classic palette" }
            InfoRow { shell: page.shell; Layout.fillWidth: true; label: "Everforest"; value: "Dark palette" }
        }

        SettingsCard {
            shell: page.shell
            Layout.fillWidth: true
            title: "Acknowledgements"
            accent: shell.uiPalette[2]

            Text {
                Layout.fillWidth: true
                text: "THANK YOU TO THE DEVELOPERS, DOCUMENTATION AUTHORS, THEME DESIGNERS AND TESTERS WHO MAKE EXPERIMENTAL LINUX DESKTOPS POSSIBLE. COMMUNITY PALETTES RETAIN THEIR ORIGINAL NAMES AND VISUAL INTENT."
                color: shell.text
                wrapMode: Text.WordWrap
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: Math.round(9 * shell.fontScale)
                font.weight: Font.Bold
                font.letterSpacing: 0.6
                lineHeight: 1.35
            }
        }
    }
}

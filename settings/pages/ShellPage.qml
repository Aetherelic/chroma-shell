import QtQuick
import QtQuick.Layouts
import Quickshell
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
            index: "07"
            title: "Shell Settings"
        }

        SettingsCard {
            shell: page.shell
            Layout.fillWidth: true
            title: "Active palette"
            accent: shell.uiPalette[0]

            GridLayout {
                Layout.fillWidth: true
                columns: 4
                rowSpacing: 8
                columnSpacing: 8

                Repeater {
                    model: shell.themeCount

                    Rectangle {
                        id: themeCard
                        required property int index
                        property var theme: shell.themeAt(index)
                        property bool selected: shell.themeIndex === index

                        Layout.fillWidth: true
                        Layout.preferredHeight: 70
                        color: selected
                            ? theme.colours[0]
                            : themeMouse.containsMouse
                                ? theme.surfaceHover
                                : theme.surface
                        border.width: selected ? 0 : shell.borderWidth
                        border.color: theme.border
                        radius: shell.cardRadius

                        ColumnLayout {
                            anchors { fill: parent; margins: 9 }
                            spacing: 4

                            Text {
                                Layout.fillWidth: true
                                text: themeCard.theme.name
                                color: themeCard.selected
                                    ? themeCard.theme.ink
                                    : themeCard.theme.text
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: Math.round(9 * shell.fontScale)
                                font.weight: Font.Black
                                elide: Text.ElideRight
                            }

                            Item { Layout.fillHeight: true }

                            Row {
                                spacing: 3
                                Repeater {
                                    model: themeCard.theme.spectrum.length
                                    Rectangle {
                                        required property int index
                                        width: 11
                                        height: 6
                                        color: themeCard.theme.spectrum[index]
                                        radius: shell.microRadius
                                    }
                                }
                            }
                        }

                        MouseArea {
                            id: themeMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: shell.applyTheme(themeCard.index)
                        }
                    }
                }
            }
        }

        SettingsCard {
            shell: page.shell
            Layout.fillWidth: true
            title: "Style Studio"
            accent: shell.uiPalette[6]

            SettingsChoice {
                shell: page.shell
                Layout.fillWidth: true
                label: "Geometry preset"
                options: ["SHARP", "TECHNICAL", "SOFT", "CAPSULE", "HYBRID"]
                current: settings.stylePreset
                accent: shell.uiPalette[6]
                onOptionSelected: value => {
                    settings.selectStylePreset(value)
                }
            }

            SettingsChoice {
                shell: page.shell
                Layout.fillWidth: true
                label: "Colour treatment"
                options: ["FULL PALETTE", "ACCENT ONLY", "DUOTONE", "MONOCHROME", "SPECTRUM", "MUTED"]
                current: settings.colorTreatment
                accent: shell.uiPalette[4]
                onOptionSelected: value => {
                    settings.colorTreatment = value
                    settings.scheduleSave()
                }
            }

            SettingsChoice {
                shell: page.shell
                Layout.fillWidth: true
                label: "Workspace geometry"
                options: ["BLOCKS", "PILLS", "DOTS"]
                current: settings.workspaceStyle
                accent: shell.uiPalette[3]
                onOptionSelected: value => {
                    settings.workspaceStyle = value
                    settings.scheduleSave()
                }
            }
        }

        SettingsCard {
            shell: page.shell
            Layout.fillWidth: true
            title: "Geometry"
            accent: shell.uiPalette[5]

            SettingsStepper {
                shell: page.shell
                Layout.fillWidth: true
                label: "Bar height"
                value: settings.barHeight
                minimum: 56
                maximum: 92
                step: 2
                suffix: "px"
                accent: shell.uiPalette[5]
                onValueSelected: next => {
                    settings.barHeight = Math.round(next)
                    settings.scheduleSave()
                }
            }

            SettingsStepper {
                shell: page.shell
                Layout.fillWidth: true
                label: "Outer margin"
                value: settings.outerMargin
                minimum: 0
                maximum: 28
                step: 2
                suffix: "px"
                accent: shell.uiPalette[4]
                onValueSelected: next => {
                    settings.outerMargin = Math.round(next)
                    settings.scheduleSave()
                }
            }

            SettingsStepper {
                shell: page.shell
                Layout.fillWidth: true
                label: "Module gap"
                value: settings.moduleGap
                minimum: 2
                maximum: 18
                step: 1
                suffix: "px"
                accent: shell.uiPalette[3]
                onValueSelected: next => {
                    settings.moduleGap = Math.round(next)
                    settings.scheduleSave()
                }
            }

            SettingsStepper {
                shell: page.shell
                Layout.fillWidth: true
                label: "Media width"
                value: settings.mediaModuleWidth
                minimum: 420
                maximum: 760
                step: 20
                suffix: "px"
                accent: shell.uiPalette[0]
                onValueSelected: next => {
                    settings.mediaModuleWidth = Math.round(next)
                    settings.scheduleSave()
                }
            }

            SettingsStepper {
                shell: page.shell
                Layout.fillWidth: true
                label: "Border thickness"
                value: settings.borderThickness
                minimum: 0
                maximum: 3
                step: 1
                suffix: "px"
                accent: shell.uiPalette[2]
                onValueSelected: next => {
                    settings.borderThickness = Math.round(next)
                    settings.scheduleSave()
                }
            }

            SettingsStepper {
                shell: page.shell
                Layout.fillWidth: true
                label: "Font scale"
                value: settings.fontScale
                minimum: 0.85
                maximum: 1.25
                step: 0.05
                decimals: 2
                suffix: "×"
                accent: shell.uiPalette[4]
                onValueSelected: next => {
                    settings.fontScale = next
                    settings.scheduleSave()
                }
            }

            SettingsStepper {
                shell: page.shell
                Layout.fillWidth: true
                label: "Icon scale"
                value: settings.iconScale
                minimum: 0.80
                maximum: 1.30
                step: 0.05
                decimals: 2
                suffix: "×"
                accent: shell.uiPalette[6]
                onValueSelected: next => {
                    settings.iconScale = next
                    settings.scheduleSave()
                }
            }

            SettingsStepper {
                shell: page.shell
                Layout.fillWidth: true
                label: "Panel padding"
                value: settings.panelPadding
                minimum: 10
                maximum: 30
                step: 2
                suffix: "px"
                accent: shell.uiPalette[1]
                onValueSelected: next => {
                    settings.panelPadding = Math.round(next)
                    settings.scheduleSave()
                }
            }
        }

        SettingsCard {
            shell: page.shell
            Layout.fillWidth: true
            title: "Desktop identity"
            accent: shell.uiPalette[4]

            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                SettingsButton {
                    shell: page.shell
                    Layout.fillWidth: true
                    label: "Wallpaper selector"
                    accent: shell.uiPalette[4]
                    filled: true
                    onClicked: Quickshell.execDetached([
                        "bash",
                        Quickshell.env("HOME") + "/.local/bin/chroma-wallpaper",
                        "select"
                    ])
                }

                SettingsButton {
                    shell: page.shell
                    Layout.fillWidth: true
                    label: shell.doNotDisturb ? "DND enabled" : "DND disabled"
                    accent: shell.warning
                    filled: shell.doNotDisturb
                    onClicked: shell.doNotDisturb = !shell.doNotDisturb
                }
            }

            SettingsChoice {
                shell: page.shell
                Layout.fillWidth: true
                label: "CAVA gradient"
                options: ["THEME", "ACCENT", "DUOTONE", "RAINBOW", "FREQUENCY", "MONOCHROME"]
                current: settings.spectrumMode
                accent: shell.uiPalette[6]
                onOptionSelected: value => {
                    settings.spectrumMode = value
                    settings.scheduleSave()
                }
            }
        }

        SettingsCard {
            shell: page.shell
            Layout.fillWidth: true
            title: "Bar placement"
            accent: shell.uiPalette[5]

            SettingsChoice {
                shell: page.shell
                Layout.fillWidth: true
                label: "Bar edge"
                options: ["TOP", "BOTTOM"]
                current: settings.barPosition
                accent: shell.uiPalette[5]
                onOptionSelected: value => {
                    settings.barPosition = value
                    settings.scheduleSave()
                }
            }

            SettingsChoice {
                shell: page.shell
                Layout.fillWidth: true
                label: "Bar monitor"
                options: ["DP-1", "HDMI-A-1"]
                current: settings.barMonitor
                accent: shell.uiPalette[4]
                onOptionSelected: value => {
                    settings.barMonitor = value
                    settings.scheduleSave()
                }
            }
        }

        SettingsCard {
            shell: page.shell
            Layout.fillWidth: true
            title: "Motion and time"
            accent: shell.uiPalette[3]

            SettingsChoice {
                shell: page.shell
                Layout.fillWidth: true
                label: "Animation speed"
                options: ["FAST", "BALANCED", "CINEMATIC"]
                current: settings.animationSpeed
                accent: shell.uiPalette[3]
                onOptionSelected: value => {
                    settings.animationSpeed = value
                    settings.scheduleSave()
                }
            }

            SettingsChoice {
                shell: page.shell
                Layout.fillWidth: true
                label: "Clock format"
                options: ["24H", "12H"]
                current: settings.clockFormat
                accent: shell.uiPalette[4]
                onOptionSelected: value => {
                    settings.clockFormat = value
                    settings.scheduleSave()
                }
            }

            SettingsChoice {
                shell: page.shell
                Layout.fillWidth: true
                label: "Date format"
                options: ["SHORT", "ISO", "VERBOSE"]
                current: settings.dateFormat
                accent: shell.uiPalette[2]
                onOptionSelected: value => {
                    settings.dateFormat = value
                    settings.scheduleSave()
                }
            }
        }

        SettingsCard {
            shell: page.shell
            Layout.fillWidth: true
            title: "Notifications and launcher"
            accent: shell.uiPalette[0]

            SettingsStepper {
                shell: page.shell
                Layout.fillWidth: true
                label: "Notification duration"
                value: settings.notificationTimeout
                minimum: 2
                maximum: 20
                step: 1
                suffix: "s"
                accent: shell.uiPalette[0]
                onValueSelected: next => {
                    settings.notificationTimeout = Math.round(next)
                    settings.scheduleSave()
                }
            }

            SettingsStepper {
                shell: page.shell
                Layout.fillWidth: true
                label: "Launcher results"
                value: settings.launcherResults
                minimum: 3
                maximum: 10
                step: 1
                accent: shell.uiPalette[4]
                onValueSelected: next => {
                    settings.launcherResults = Math.round(next)
                    settings.scheduleSave()
                }
            }
        }

        SettingsCard {
            shell: page.shell
            Layout.fillWidth: true
            title: "On-screen display"
            accent: shell.uiPalette[2]

            SettingsChoice {
                shell: page.shell
                Layout.fillWidth: true
                label: "OSD edge"
                options: ["TOP", "BOTTOM"]
                current: settings.osdPosition
                accent: shell.uiPalette[2]
                onOptionSelected: value => {
                    settings.osdPosition = value
                    settings.scheduleSave()
                }
            }

            SettingsStepper {
                shell: page.shell
                Layout.fillWidth: true
                label: "OSD duration"
                value: settings.osdDuration
                minimum: 0.6
                maximum: 4.0
                step: 0.2
                decimals: 1
                suffix: "s"
                accent: shell.uiPalette[2]
                onValueSelected: next => {
                    settings.osdDuration = next
                    settings.scheduleSave()
                }
            }
        }

        SettingsCard {
            shell: page.shell
            Layout.fillWidth: true
            title: "Restore"
            accent: shell.error

            RowLayout {
                Layout.fillWidth: true

                Text {
                    Layout.fillWidth: true
                    text: "RESET LIVE UI CONFIGURATION"
                    color: shell.text
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: Math.round(9 * shell.fontScale)
                    font.weight: Font.Black
                    font.letterSpacing: 0.8
                }

                SettingsButton {
                    shell: page.shell
                    label: "Reset defaults"
                    danger: true
                    onClicked: settings.resetDefaults()
                }
            }
        }
    }
}

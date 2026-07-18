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
            index: "04"
            title: "Widgets"
            subtitle: "Live composition controls saved to ~/.config/chroma/settings.json"
        }

        SettingsCard {
            shell: page.shell
            Layout.fillWidth: true
            title: "Bar composition"
            subtitle: "Every switch applies immediately and survives a CHROMA restart"
            accent: shell.uiPalette[3]

            SettingsToggle {
                shell: page.shell
                Layout.fillWidth: true
                label: "Workspace rail"
                description: "Numbered workspace controls and occupied indicators"
                checked: settings.showWorkspaces
                onToggled: value => {
                    settings.showWorkspaces = value
                    settings.scheduleSave()
                }
            }

            SettingsToggle {
                shell: page.shell
                Layout.fillWidth: true
                label: "Now playing"
                description: "Media metadata, progress and expanded player drawer"
                checked: settings.showMedia
                onToggled: value => {
                    settings.showMedia = value
                    settings.scheduleSave()
                }
            }

            SettingsToggle {
                shell: page.shell
                Layout.fillWidth: true
                enabled: settings.showMedia
                label: "Album artwork"
                description: "Artwork in the compact player and expanded media drawer"
                checked: settings.showAlbumArt
                onToggled: value => {
                    settings.showAlbumArt = value
                    settings.scheduleSave()
                }
            }

            SettingsToggle {
                shell: page.shell
                Layout.fillWidth: true
                enabled: settings.showMedia
                label: "Audio spectrum"
                description: "Real PipeWire CAVA spectrum inside both media surfaces"
                checked: settings.showSpectrum
                onToggled: value => {
                    settings.showSpectrum = value
                    settings.scheduleSave()
                }
            }

            SettingsToggle {
                shell: page.shell
                Layout.fillWidth: true
                label: "Notification control"
                description: "Signal history and Do Not Disturb button"
                checked: settings.showNotifications
                onToggled: value => {
                    settings.showNotifications = value
                    settings.scheduleSave()
                }
            }

            SettingsToggle {
                shell: page.shell
                Layout.fillWidth: true
                label: "Notification toasts"
                description: "Keep notifications in history while suppressing pop-up cards"
                checked: settings.showNotificationToasts
                onToggled: value => {
                    settings.showNotificationToasts = value
                    settings.scheduleSave()
                }
            }

            SettingsToggle {
                shell: page.shell
                Layout.fillWidth: true
                label: "Theme control"
                description: "Palette browser and theme cycle button"
                checked: settings.showThemes
                onToggled: value => {
                    settings.showThemes = value
                    settings.scheduleSave()
                }
            }

            SettingsToggle {
                shell: page.shell
                Layout.fillWidth: true
                label: "Control centre"
                description: "Audio, network, Bluetooth and session controls"
                checked: settings.showControl
                onToggled: value => {
                    settings.showControl = value
                    settings.scheduleSave()
                }
            }

            SettingsToggle {
                shell: page.shell
                Layout.fillWidth: true
                label: "Clock"
                description: "Time block and animated theme accent"
                checked: settings.showClock
                onToggled: value => {
                    settings.showClock = value
                    settings.scheduleSave()
                }
            }

            SettingsToggle {
                shell: page.shell
                Layout.fillWidth: true
                enabled: settings.showClock
                label: "Date"
                description: "Secondary date line beneath the clock"
                checked: settings.showDate
                onToggled: value => {
                    settings.showDate = value
                    settings.scheduleSave()
                }
            }

            SettingsToggle {
                shell: page.shell
                Layout.fillWidth: true
                label: "Volume and brightness OSD"
                description: "Animated feedback from hardware and media keys"
                checked: settings.showOsd
                onToggled: value => {
                    settings.showOsd = value
                    settings.scheduleSave()
                }
            }
        }

        SettingsCard {
            shell: page.shell
            Layout.fillWidth: true
            title: "Bar density"
            subtitle: "One coordinated preset controls bar height, spacing and module scale"
            accent: shell.uiPalette[5]

            SettingsChoice {
                shell: page.shell
                Layout.fillWidth: true
                label: "Density preset"
                description: "Compact, balanced or spacious geometry"
                options: ["COMPACT", "BALANCED", "SPACIOUS"]
                current: settings.density
                accent: shell.uiPalette[5]
                onOptionSelected: value => {
                    settings.density = value
                    settings.scheduleSave()
                }
            }
        }

        SettingsCard {
            shell: page.shell
            Layout.fillWidth: true
            title: "Workspaces"
            subtitle: "Controls how many workspace tiles CHROMA renders"
            accent: shell.uiPalette[4]

            SettingsStepper {
                shell: page.shell
                Layout.fillWidth: true
                label: "Workspace count"
                description: "Visible numbered workspaces"
                value: settings.workspaceCount
                minimum: 1
                maximum: 10
                step: 1
                accent: shell.uiPalette[4]
                onValueSelected: next => {
                    settings.workspaceCount = Math.round(next)
                    settings.scheduleSave()
                }
            }
        }

        SettingsCard {
            shell: page.shell
            Layout.fillWidth: true
            enabled: settings.showSpectrum
            title: "CAVA visualiser"
            subtitle: "Real audio processing controls applied to the running spectrum"
            accent: shell.uiPalette[6]

            SettingsStepper {
                shell: page.shell
                Layout.fillWidth: true
                label: "Spectrum bars"
                description: "Frequency columns rendered in the player"
                value: settings.spectrumBars
                minimum: 12
                maximum: 40
                step: 4
                accent: shell.uiPalette[6]
                onValueSelected: next => {
                    settings.spectrumBars = Math.round(next)
                    settings.scheduleSave()
                }
            }

            SettingsStepper {
                shell: page.shell
                Layout.fillWidth: true
                label: "Sensitivity"
                description: "Amplifies or calms incoming PipeWire levels"
                value: settings.spectrumSensitivity
                minimum: 0.5
                maximum: 2.0
                step: 0.1
                decimals: 1
                suffix: "×"
                accent: shell.uiPalette[3]
                onValueSelected: next => {
                    settings.spectrumSensitivity = next
                    settings.scheduleSave()
                }
            }

            SettingsStepper {
                shell: page.shell
                Layout.fillWidth: true
                label: "Smoothing"
                description: "Higher values retain more of the previous frame"
                value: settings.spectrumSmoothing * 100
                minimum: 5
                maximum: 85
                step: 5
                suffix: "%"
                accent: shell.uiPalette[4]
                onValueSelected: next => {
                    settings.spectrumSmoothing = next / 100
                    settings.scheduleSave()
                }
            }
        }
    }
}

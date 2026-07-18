import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import "../components"

Flickable {
    id: page

    required property var shell
    required property var settings

    property string output: "READY // SELECT A MAINTENANCE ACTION"

    contentWidth: width
    contentHeight: content.implicitHeight + 28
    clip: true

    function runBackend(action) {
        actionProcess.exec([
            "bash",
            Quickshell.shellPath("backend/chroma-settingsctl"),
            action
        ])
    }

    Process {
        id: actionProcess
        stdout: StdioCollector {
            onStreamFinished: page.output = text.trim().length > 0
                ? text.trim()
                : "ACTION COMPLETED"
        }
        stderr: StdioCollector {
            onStreamFinished: {
                if (text.trim().length > 0) {
                    page.output = text.trim()
                }
            }
        }
    }

    ColumnLayout {
        id: content
        width: page.width
        spacing: 16

        PageHeader {
            shell: page.shell
            index: "06"
            title: "Config"
            subtitle: "Maintenance tools, source locations, diagnostics and snapshots"
        }

        SettingsCard {
            shell: page.shell
            Layout.fillWidth: true
            title: "Open configuration"
            subtitle: "Launch the relevant directory or file using your configured tools"
            accent: shell.uiPalette[4]

            GridLayout {
                Layout.fillWidth: true
                columns: 3
                rowSpacing: 10
                columnSpacing: 10

                SettingsButton {
                    shell: page.shell
                    Layout.fillWidth: true
                    label: "CHROMA project"
                    sublabel: "QML source"
                    onClicked: page.runBackend("open-project")
                }

                SettingsButton {
                    shell: page.shell
                    Layout.fillWidth: true
                    label: "Hyprland"
                    sublabel: "User config"
                    onClicked: page.runBackend("open-hyprland")
                }

                SettingsButton {
                    shell: page.shell
                    Layout.fillWidth: true
                    label: "NixOS"
                    sublabel: "System config"
                    onClicked: page.runBackend("open-nixos")
                }

                SettingsButton {
                    shell: page.shell
                    Layout.fillWidth: true
                    label: "CHROMA state"
                    sublabel: "Persistent JSON"
                    onClicked: page.runBackend("open-state")
                }

                SettingsButton {
                    shell: page.shell
                    Layout.fillWidth: true
                    label: "Quickshell log"
                    sublabel: "Runtime output"
                    onClicked: page.runBackend("open-log")
                }

                SettingsButton {
                    shell: page.shell
                    Layout.fillWidth: true
                    label: "Wallpaper config"
                    sublabel: "Daemon state"
                    onClicked: page.runBackend("open-wallpaper")
                }
            }
        }

        SettingsCard {
            shell: page.shell
            Layout.fillWidth: true
            title: "Runtime operations"
            subtitle: "Safe reloads and diagnostic capture"
            accent: shell.uiPalette[3]

            GridLayout {
                Layout.fillWidth: true
                columns: 3
                rowSpacing: 10
                columnSpacing: 10

                SettingsButton {
                    shell: page.shell
                    Layout.fillWidth: true
                    label: "Reload CHROMA"
                    accent: shell.uiPalette[4]
                    filled: true
                    onClicked: page.runBackend("restart-shell")
                }

                SettingsButton {
                    shell: page.shell
                    Layout.fillWidth: true
                    label: "Reload Hyprland"
                    accent: shell.uiPalette[3]
                    onClicked: page.runBackend("reload-hyprland")
                }

                SettingsButton {
                    shell: page.shell
                    Layout.fillWidth: true
                    label: "Health check"
                    accent: shell.uiPalette[6]
                    onClicked: page.runBackend("health")
                }

                SettingsButton {
                    shell: page.shell
                    Layout.fillWidth: true
                    label: "Create snapshot"
                    sublabel: "Timestamped archive"
                    onClicked: page.runBackend("snapshot")
                }

                SettingsButton {
                    shell: page.shell
                    Layout.fillWidth: true
                    label: "Copy diagnostics"
                    sublabel: "Clipboard report"
                    onClicked: page.runBackend("copy-report")
                }

                SettingsButton {
                    shell: page.shell
                    Layout.fillWidth: true
                    label: "Open backups"
                    sublabel: "Recovery points"
                    onClicked: page.runBackend("open-backups")
                }
            }
        }

        SettingsCard {
            shell: page.shell
            Layout.fillWidth: true
            title: "Command output"
            subtitle: "Most recent settings operation"
            accent: shell.uiPalette[0]

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 150
                color: shell.backgroundAlt
                border.width: shell.borderWidth
                border.color: shell.border
                radius: shell.cardRadius

                Text {
                    anchors {
                        fill: parent
                        margins: 12
                    }
                    text: page.output
                    color: shell.text
                    wrapMode: Text.WrapAnywhere
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: Math.round(8 * shell.fontScale)
                    font.weight: Font.Bold
                }
            }
        }
    }
}

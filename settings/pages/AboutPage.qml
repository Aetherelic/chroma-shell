import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import "../components"

Flickable {
    id: page

    required property var shell
    required property var settings

    property var info: ({})
    property string rawError: ""

    contentWidth: width
    contentHeight: content.implicitHeight + 28
    clip: true

    function refresh() {
        infoProcess.exec([
            "bash",
            Quickshell.shellPath("backend/chroma-settingsctl"),
            "system-json"
        ])
    }

    Process {
        id: infoProcess
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    page.info = JSON.parse(text)
                    page.rawError = ""
                } catch (error) {
                    page.rawError = text
                }
            }
        }
        stderr: StdioCollector {
            onStreamFinished: {
                if (text.trim().length > 0) {
                    page.rawError = text.trim()
                }
            }
        }
    }

    Component.onCompleted: refresh()

    ColumnLayout {
        id: content
        width: page.width
        spacing: 16

        PageHeader {
            shell: page.shell
            index: "08"
            title: "About System"
            subtitle: "Live operating system, hardware and shell diagnostics"
        }

        SettingsCard {
            shell: page.shell
            Layout.fillWidth: true
            title: "System identity"
            subtitle: "NixOS host and active software stack"
            accent: shell.uiPalette[4]

            InfoRow { shell: page.shell; Layout.fillWidth: true; label: "Hostname"; value: page.info.hostname || "LOADING" }
            InfoRow { shell: page.shell; Layout.fillWidth: true; label: "Operating system"; value: page.info.os || "—" }
            InfoRow { shell: page.shell; Layout.fillWidth: true; label: "Kernel"; value: page.info.kernel || "—" }
            InfoRow { shell: page.shell; Layout.fillWidth: true; label: "Uptime"; value: page.info.uptime || "—" }
            InfoRow { shell: page.shell; Layout.fillWidth: true; label: "NixOS generation"; value: page.info.generation || "—" }
        }

        SettingsCard {
            shell: page.shell
            Layout.fillWidth: true
            title: "Hardware"
            subtitle: "Processor, graphics, memory and root storage"
            accent: shell.uiPalette[1]

            InfoRow { shell: page.shell; Layout.fillWidth: true; label: "CPU"; value: page.info.cpu || "—" }
            InfoRow { shell: page.shell; Layout.fillWidth: true; label: "GPU"; value: page.info.gpu || "—" }
            InfoRow { shell: page.shell; Layout.fillWidth: true; label: "Memory"; value: page.info.memory || "—" }
            InfoRow { shell: page.shell; Layout.fillWidth: true; label: "Root storage"; value: page.info.storage || "—" }
            InfoRow { shell: page.shell; Layout.fillWidth: true; label: "Displays"; value: page.info.displays || "—" }
        }

        SettingsCard {
            shell: page.shell
            Layout.fillWidth: true
            title: "Desktop stack"
            subtitle: "Current compositor and CHROMA runtime"
            accent: shell.uiPalette[6]

            InfoRow { shell: page.shell; Layout.fillWidth: true; label: "Hyprland"; value: page.info.hyprland || "—" }
            InfoRow { shell: page.shell; Layout.fillWidth: true; label: "Quickshell"; value: page.info.quickshell || "—" }
            InfoRow { shell: page.shell; Layout.fillWidth: true; label: "CHROMA PID"; value: page.info.chromaPid || Quickshell.processId.toString() }
            InfoRow { shell: page.shell; Layout.fillWidth: true; label: "Theme"; value: shell.themeName }

            RowLayout {
                Layout.fillWidth: true

                SettingsButton {
                    shell: page.shell
                    label: "Refresh"
                    accent: shell.uiPalette[4]
                    onClicked: page.refresh()
                }

                SettingsButton {
                    shell: page.shell
                    label: "Copy report"
                    accent: shell.uiPalette[3]
                    onClicked: Quickshell.execDetached([
                        "bash",
                        Quickshell.shellPath("backend/chroma-settingsctl"),
                        "copy-report"
                    ])
                }
            }
        }

        Text {
            visible: page.rawError.length > 0
            Layout.fillWidth: true
            text: page.rawError
            color: shell.error
            wrapMode: Text.WrapAnywhere
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: Math.round(8 * shell.fontScale)
        }
    }
}

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Bluetooth
import Quickshell.Widgets
import "../components"

Flickable {
    id: page

    required property var shell
    required property var settings

    property var adapter: Bluetooth.defaultAdapter
    property var devices: adapter !== null ? adapter.devices.values : []

    contentWidth: width
    contentHeight: content.implicitHeight + 28
    clip: true

    ColumnLayout {
        id: content
        width: page.width
        spacing: 16

        PageHeader {
            shell: page.shell
            index: "02"
            title: "Bluetooth"
            subtitle: "BlueZ adapter, discovery, pairing, trust and connection control"
        }

        SettingsCard {
            shell: page.shell
            Layout.fillWidth: true
            title: "Bluetooth adapter"
            subtitle: page.adapter !== null
                ? (page.adapter.name || page.adapter.adapterId || "DEFAULT ADAPTER")
                : "NO BLUEZ ADAPTER DETECTED"
            accent: shell.uiPalette[6]

            SettingsToggle {
                shell: page.shell
                Layout.fillWidth: true
                label: "Bluetooth radio"
                description: page.adapter === null
                    ? "No adapter is available"
                    : page.adapter.enabled
                        ? "Adapter powered and ready"
                        : "Adapter disabled"
                checked: page.adapter !== null && page.adapter.enabled
                onToggled: value => {
                    if (page.adapter !== null) {
                        page.adapter.enabled = value
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true

                Text {
                    Layout.fillWidth: true
                    text: page.adapter !== null && page.adapter.discovering
                        ? "DISCOVERY CHANNEL ACTIVE"
                        : page.devices.length + " DEVICES TRACKED"
                    color: shell.muted
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: Math.round(8 * shell.fontScale)
                    font.weight: Font.Bold
                    font.letterSpacing: 0.8
                }

                SettingsButton {
                    shell: page.shell
                    label: page.adapter !== null && page.adapter.discovering
                        ? "Stop scan"
                        : "Scan"
                    accent: shell.uiPalette[6]
                    enabled: page.adapter !== null && page.adapter.enabled
                    onClicked: {
                        page.adapter.discovering = !page.adapter.discovering
                        if (page.adapter.discovering) {
                            scanTimer.restart()
                        }
                    }
                }

                SettingsButton {
                    shell: page.shell
                    label: page.adapter !== null && page.adapter.discoverable
                        ? "Visible"
                        : "Hidden"
                    accent: shell.uiPalette[3]
                    enabled: page.adapter !== null && page.adapter.enabled
                    onClicked: page.adapter.discoverable = !page.adapter.discoverable
                }
            }
        }

        SettingsCard {
            shell: page.shell
            Layout.fillWidth: true
            title: "Devices"
            subtitle: "Pair, trust and connect nearby or remembered Bluetooth hardware"
            accent: shell.uiPalette[4]

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 8

                Repeater {
                    model: page.devices

                    Rectangle {
                        id: deviceRow
                        required property var modelData

                        Layout.fillWidth: true
                        Layout.preferredHeight: 72
                        color: modelData.connected
                            ? shell.surfaceAlt
                            : pointer.containsMouse
                                ? shell.surfaceHover
                                : shell.backgroundAlt
                        border.width: modelData.connected ? 2 : 1
                        border.color: modelData.connected
                            ? shell.success
                            : shell.border
                        radius: shell.cardRadius

                        RowLayout {
                            anchors {
                                fill: parent
                                leftMargin: 14
                                rightMargin: 12
                            }
                            spacing: 12

                            Rectangle {
                                Layout.preferredWidth: 42
                                Layout.preferredHeight: 42
                                color: modelData.connected ? shell.success : shell.surface
                                border.width: modelData.connected ? 0 : shell.borderWidth
                                border.color: shell.border
                                radius: shell.cardRadius

                                IconImage {
                                    anchors {
                                        fill: parent
                                        margins: 10
                                    }
                                    source: Quickshell.iconPath(
                                        deviceRow.modelData.icon || "bluetooth",
                                        "bluetooth"
                                    )
                                }
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 3

                                Text {
                                    Layout.fillWidth: true
                                    text: deviceRow.modelData.name
                                        || deviceRow.modelData.deviceName
                                        || "UNNAMED DEVICE"
                                    color: shell.textStrong
                                    font.family: "JetBrainsMono Nerd Font"
                                    font.pixelSize: Math.round(11 * shell.fontScale)
                                    font.weight: Font.Black
                                    elide: Text.ElideRight
                                }

                                Text {
                                    Layout.fillWidth: true
                                    text: (deviceRow.modelData.connected ? "CONNECTED" : "AVAILABLE")
                                        + (deviceRow.modelData.paired ? " // PAIRED" : "")
                                        + (deviceRow.modelData.trusted ? " // TRUSTED" : "")
                                        + (deviceRow.modelData.batteryAvailable
                                            ? " // " + Math.round(deviceRow.modelData.battery * 100) + "%"
                                            : "")
                                    color: shell.muted
                                    font.family: "JetBrainsMono Nerd Font"
                                    font.pixelSize: Math.round(7 * shell.fontScale)
                                    font.weight: Font.Bold
                                    font.letterSpacing: 0.5
                                }
                            }

                            SettingsButton {
                                shell: page.shell
                                label: deviceRow.modelData.pairing
                                    ? "Cancel"
                                    : !deviceRow.modelData.paired
                                        ? "Pair"
                                        : deviceRow.modelData.connected
                                            ? "Disconnect"
                                            : "Connect"
                                accent: deviceRow.modelData.connected
                                    ? shell.error
                                    : shell.uiPalette[4]
                                onClicked: {
                                    if (deviceRow.modelData.pairing) {
                                        deviceRow.modelData.cancelPair()
                                    } else if (!deviceRow.modelData.paired) {
                                        deviceRow.modelData.pair()
                                    } else if (deviceRow.modelData.connected) {
                                        deviceRow.modelData.disconnect()
                                    } else {
                                        deviceRow.modelData.connect()
                                    }
                                }
                            }

                            SettingsButton {
                                visible: deviceRow.modelData.paired
                                shell: page.shell
                                label: deviceRow.modelData.trusted ? "Trusted" : "Trust"
                                accent: shell.uiPalette[3]
                                filled: deviceRow.modelData.trusted
                                onClicked: deviceRow.modelData.trusted = !deviceRow.modelData.trusted
                            }

                            SettingsButton {
                                visible: deviceRow.modelData.paired
                                shell: page.shell
                                label: "Forget"
                                danger: true
                                onClicked: deviceRow.modelData.forget()
                            }
                        }

                        MouseArea {
                            id: pointer
                            anchors.fill: parent
                            acceptedButtons: Qt.NoButton
                            hoverEnabled: true
                        }
                    }
                }

                Text {
                    visible: page.devices.length === 0
                    Layout.fillWidth: true
                    Layout.preferredHeight: 100
                    text: page.adapter !== null && page.adapter.enabled
                        ? "NO DEVICES TRACKED // START DISCOVERY"
                        : "BLUETOOTH ADAPTER IS OFFLINE"
                    color: shell.dim
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: Math.round(9 * shell.fontScale)
                    font.weight: Font.Bold
                    font.letterSpacing: 1
                }
            }
        }
    }

    Timer {
        id: scanTimer
        interval: 20000
        repeat: false
        onTriggered: {
            if (page.adapter !== null) {
                page.adapter.discovering = false
            }
        }
    }
}

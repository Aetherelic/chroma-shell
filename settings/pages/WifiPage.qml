import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Networking
import "../components"

Flickable {
    id: page

    required property var shell
    required property var settings

    property var selectedNetwork: null
    property var wifiDevice: {
        var devices = Networking.devices.values
        for (var index = 0; index < devices.length; index++) {
            var device = devices[index]
            if (device && device.networks !== undefined) {
                return device
            }
        }
        return null
    }

    property var networks:
        wifiDevice !== null ? wifiDevice.networks.values : []

    contentWidth: width
    contentHeight: content.implicitHeight + 28
    clip: true

    function securityLabel(network) {
        if (!network) {
            return "UNKNOWN"
        }
        return WifiSecurityType.toString(network.security)
            .replace(/([a-z])([A-Z])/g, "$1 $2")
            .toUpperCase()
    }

    ColumnLayout {
        id: content
        width: page.width
        spacing: 16

        PageHeader {
            shell: page.shell
            index: "01"
            title: "Wi-Fi"
            subtitle: "NetworkManager radio, scanning, profiles and secure connection control"
        }

        SettingsCard {
            shell: page.shell
            Layout.fillWidth: true
            title: "Wireless adapter"
            subtitle: page.wifiDevice !== null
                ? "LIVE DEVICE // " + (page.wifiDevice.name || "WIRELESS")
                : "NO WIRELESS DEVICE DETECTED"
            accent: shell.uiPalette[4]

            SettingsToggle {
                shell: page.shell
                Layout.fillWidth: true
                label: "Wi-Fi radio"
                description: Networking.wifiEnabled
                    ? "Wireless networking is enabled"
                    : "Wireless networking is disabled"
                checked: Networking.wifiEnabled
                onToggled: value => Networking.wifiEnabled = value
            }

            RowLayout {
                Layout.fillWidth: true

                Text {
                    Layout.fillWidth: true
                    text: page.wifiDevice !== null && page.wifiDevice.scannerEnabled
                        ? "SCANNING THE LOCAL SPECTRUM..."
                        : page.networks.length + " NETWORKS IN INDEX"
                    color: shell.muted
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: Math.round(8 * shell.fontScale)
                    font.weight: Font.Bold
                    font.letterSpacing: 0.8
                }

                SettingsButton {
                    shell: page.shell
                    label: page.wifiDevice !== null && page.wifiDevice.scannerEnabled
                        ? "Scanning"
                        : "Scan"
                    accent: shell.uiPalette[4]
                    enabled: page.wifiDevice !== null && Networking.wifiEnabled
                    onClicked: {
                        page.wifiDevice.scannerEnabled = true
                        scanTimer.restart()
                    }
                }
            }
        }

        SettingsCard {
            visible: page.selectedNetwork !== null
            shell: page.shell
            Layout.fillWidth: true
            title: page.selectedNetwork !== null
                ? "Authenticate // " + page.selectedNetwork.name
                : "Authenticate"
            subtitle: "Enter the wireless passphrase; it is sent directly to NetworkManager"
            accent: shell.uiPalette[6]

            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                SettingsTextField {
                    id: passphrase
                    shell: page.shell
                    Layout.fillWidth: true
                    placeholder: "Network passphrase"
                    prefix: "KEY"
                    echoMode: TextInput.Password
                    onAccepted: connectButton.clicked()
                }

                SettingsButton {
                    id: connectButton
                    shell: page.shell
                    label: "Connect"
                    accent: shell.uiPalette[3]
                    filled: true
                    enabled: passphrase.text.length >= 8
                    onClicked: {
                        if (page.selectedNetwork !== null) {
                            page.selectedNetwork.connectWithPsk(passphrase.text)
                            passphrase.text = ""
                            page.selectedNetwork = null
                        }
                    }
                }

                SettingsButton {
                    shell: page.shell
                    label: "Cancel"
                    onClicked: {
                        passphrase.text = ""
                        page.selectedNetwork = null
                    }
                }
            }
        }

        SettingsCard {
            shell: page.shell
            Layout.fillWidth: true
            title: "Available networks"
            subtitle: "Known profiles connect immediately; secured new networks request a key"
            accent: shell.uiPalette[3]

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 8

                Repeater {
                    model: page.networks

                    Rectangle {
                        id: networkRow
                        required property var modelData

                        Layout.fillWidth: true
                        Layout.preferredHeight: 66
                        color: modelData.connected
                            ? shell.surfaceAlt
                            : networkMouse.containsMouse
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
                                Layout.preferredWidth: 40
                                Layout.preferredHeight: 40
                                color: modelData.connected
                                    ? shell.success
                                    : shell.surface
                                border.width: modelData.connected ? 0 : shell.borderWidth
                                border.color: shell.border
                                radius: shell.cardRadius

                                Column {
                                    anchors.centerIn: parent
                                    spacing: 2

                                    Repeater {
                                        model: 3
                                        Rectangle {
                                            required property int index
                                            width: 8 + index * 5
                                            height: 3
                                            color: networkRow.modelData.signalStrength * 3 > index
                                                ? (networkRow.modelData.connected
                                                    ? shell.ink
                                                    : shell.uiPalette[4])
                                                : shell.borderStrong
                                        }
                                    }
                                }
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 3

                                Text {
                                    Layout.fillWidth: true
                                    text: networkRow.modelData.name || "HIDDEN NETWORK"
                                    color: shell.textStrong
                                    font.family: "JetBrainsMono Nerd Font"
                                    font.pixelSize: Math.round(11 * shell.fontScale)
                                    font.weight: Font.Black
                                    elide: Text.ElideRight
                                }

                                Text {
                                    Layout.fillWidth: true
                                    text: Math.round(networkRow.modelData.signalStrength * 100)
                                        + "% // " + page.securityLabel(networkRow.modelData)
                                        + (networkRow.modelData.known ? " // SAVED" : "")
                                    color: shell.muted
                                    font.family: "JetBrainsMono Nerd Font"
                                    font.pixelSize: Math.round(7 * shell.fontScale)
                                    font.weight: Font.Bold
                                    font.letterSpacing: 0.6
                                }
                            }

                            SettingsButton {
                                shell: page.shell
                                label: networkRow.modelData.connected
                                    ? "Disconnect"
                                    : networkRow.modelData.stateChanging
                                        ? "Working"
                                        : "Connect"
                                accent: networkRow.modelData.connected
                                    ? shell.error
                                    : shell.uiPalette[4]
                                enabled: !networkRow.modelData.stateChanging
                                onClicked: {
                                    if (networkRow.modelData.connected) {
                                        networkRow.modelData.disconnect()
                                    } else if (
                                        networkRow.modelData.known
                                        || networkRow.modelData.security === WifiSecurityType.Open
                                    ) {
                                        networkRow.modelData.connect()
                                    } else {
                                        page.selectedNetwork = networkRow.modelData
                                    }
                                }
                            }

                            SettingsButton {
                                visible: networkRow.modelData.known
                                shell: page.shell
                                label: "Forget"
                                danger: true
                                onClicked: networkRow.modelData.forget()
                            }
                        }

                        MouseArea {
                            id: networkMouse
                            anchors.fill: parent
                            acceptedButtons: Qt.NoButton
                            hoverEnabled: true
                        }
                    }
                }

                Text {
                    visible: page.networks.length === 0
                    Layout.fillWidth: true
                    Layout.preferredHeight: 90
                    text: Networking.wifiEnabled
                        ? "NO NETWORKS DISCOVERED // PRESS SCAN"
                        : "WIRELESS RADIO IS OFFLINE"
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
        interval: 9000
        repeat: false
        onTriggered: {
            if (page.wifiDevice !== null) {
                page.wifiDevice.scannerEnabled = false
            }
        }
    }
}

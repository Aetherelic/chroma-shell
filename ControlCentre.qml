import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Bluetooth
import Quickshell.Hyprland
import Quickshell.Networking
import Quickshell.Services.Pipewire
import Quickshell.Wayland

Scope {
    id: component

    required property var shell

    property bool idleInhibit: false
    property string pendingAction: ""
    property var sink: Pipewire.defaultAudioSink
    property var bluetoothAdapter: Bluetooth.defaultAdapter

    property real volume:
        sink !== null && sink.audio !== null
            ? Math.max(0, Math.min(1, sink.audio.volume))
            : 0

    property bool muted:
        sink !== null && sink.audio !== null
            ? sink.audio.muted
            : false

    property string networkLabel: {
        var devices = Networking.devices.values

        for (var deviceIndex = 0; deviceIndex < devices.length; deviceIndex++) {
            var device = devices[deviceIndex]
            if (!device) {
                continue
            }

            if (device.networks !== undefined) {
                var networks = device.networks.values
                for (var networkIndex = 0; networkIndex < networks.length; networkIndex++) {
                    var network = networks[networkIndex]
                    if (network && network.connected) {
                        return network.name || "Connected"
                    }
                }
            }

            if (device.connected) {
                return device.name || "Wired"
            }
        }

        return Networking.wifiEnabled ? "Not connected" : "Disabled"
    }

    property int connectedBluetoothCount: {
        var devices = Bluetooth.devices.values
        var count = 0
        for (var index = 0; index < devices.length; index++) {
            if (devices[index] && devices[index].connected) {
                count++
            }
        }
        return count
    }

    property string bluetoothLabel:
        bluetoothAdapter === null
            ? "No adapter"
            : !bluetoothAdapter.enabled
                ? "Disabled"
                : connectedBluetoothCount > 0
                    ? connectedBluetoothCount + " connected"
                    : "Ready"

    function setVolume(value) {
        if (sink === null || sink.audio === null) {
            return
        }

        sink.audio.volume = Math.max(0, Math.min(1, value))
    }

    function toggleMute() {
        if (sink !== null && sink.audio !== null) {
            sink.audio.muted = !sink.audio.muted
        }
    }

    function closePanel() {
        shell.controlCenterOpen = false
        pendingAction = ""
    }

    function executeAction(action) {
        pendingAction = ""
        closePanel()

        if (action === "logout") {
            Hyprland.dispatch("exit")
        } else if (action === "reboot") {
            Quickshell.execDetached(["systemctl", "reboot"])
        } else if (action === "shutdown") {
            Quickshell.execDetached(["systemctl", "poweroff"])
        }
    }

    function requestAction(action) {
        if (pendingAction === action) {
            executeAction(action)
            return
        }

        pendingAction = action
        confirmTimer.restart()
    }

    PwObjectTracker {
        objects: [ Pipewire.defaultAudioSink ]
    }

    Timer {
        id: confirmTimer
        interval: 3500
        repeat: false
        onTriggered: component.pendingAction = ""
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: controlWindow

            required property var modelData

            screen: modelData
            visible:
                modelData.name === shell.resolvedBarMonitor
                && shell.controlCenterOpen

            anchors {
                top: true
                bottom: true
                left: true
                right: true
            }

            exclusiveZone: 0
            aboveWindows: true
            color: "transparent"

            WlrLayershell.namespace: "chroma-control-centre"
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

            IdleInhibitor {
                window: controlWindow
                enabled:
                    component.idleInhibit
                    && shell.controlCenterOpen
            }

            Rectangle {
                anchors.fill: parent
                color: "#26000000"

                MouseArea {
                    anchors.fill: parent
                    onClicked: component.closePanel()
                }
            }

            Rectangle {
                id: panel

                width: 430
                height: 474

                anchors {
                    right: parent.right
                    top:
                        shell.barPosition === "TOP"
                            ? parent.top
                            : undefined
                    bottom:
                        shell.barPosition === "BOTTOM"
                            ? parent.bottom
                            : undefined
                    rightMargin: 18
                    topMargin:
                        shell.barPosition === "TOP"
                            ? shell.barHeight + 24
                            : 0
                    bottomMargin:
                        shell.barPosition === "BOTTOM"
                            ? shell.barHeight + 24
                            : 0
                }

                color: shell.background
                radius: shell.panelRadius
                border.width: shell.borderWidth
                border.color: shell.border
                clip: true

                MouseArea { anchors.fill: parent }

                Row {
                    anchors {
                        top: parent.top
                        left: parent.left
                        right: parent.right
                    }
                    height: 5

                    Repeater {
                        model: shell.spectrumPalette.length

                        Rectangle {
                            required property int index
                            width: panel.width / shell.spectrumPalette.length
                            height: 5
                            color: shell.spectrumPalette[index]
                        }
                    }
                }

                ColumnLayout {
                    anchors {
                        fill: parent
                        topMargin: 20
                        bottomMargin: 16
                        leftMargin: 16
                        rightMargin: 16
                    }
                    spacing: 12

                    RowLayout {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 42

                        Text {
                            Layout.fillWidth: true
                            text: "CHROMA // CONTROL"
                            color: shell.textStrong
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: Math.round(17 * shell.fontScale)
                            font.weight: Font.Black
                            font.letterSpacing: 0.7
                        }

                        Rectangle {
                            width: 40
                            height: 40
                            radius: shell.controlRadius
                            color: closeMouse.containsMouse
                                ? shell.uiPalette[0]
                                : shell.surface
                            border.width: closeMouse.containsMouse ? 0 : shell.borderWidth
                            border.color: shell.borderStrong

                            Text {
                                anchors.centerIn: parent
                                text: "×"
                                color: closeMouse.containsMouse
                                    ? shell.ink
                                    : shell.text
                                font.pixelSize: Math.round(21 * shell.fontScale)
                                font.weight: Font.Black
                            }

                            MouseArea {
                                id: closeMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: component.closePanel()
                            }
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 104
                        color: shell.surface
                        radius: shell.cardRadius
                        border.width: shell.borderWidth
                        border.color: shell.border

                        ColumnLayout {
                            anchors {
                                fill: parent
                                margins: 13
                            }
                            spacing: 10

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 11

                                Rectangle {
                                    Layout.preferredWidth: 42
                                    Layout.preferredHeight: 42
                                    radius: shell.controlRadius
                                    color: component.muted
                                        ? shell.error
                                        : shell.uiPalette[4]

                                    Text {
                                        anchors.centerIn: parent
                                        text: component.muted ? "×" : "♪"
                                        color: shell.ink
                                        font.pixelSize: Math.round(19 * shell.fontScale)
                                        font.weight: Font.Black
                                    }

                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: component.toggleMute()
                                    }
                                }

                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 2

                                    Text {
                                        Layout.fillWidth: true
                                        text: component.sink !== null
                                            ? (
                                                component.sink.description
                                                || component.sink.nickname
                                                || "Default output"
                                            )
                                            : "No audio output"
                                        color: shell.textStrong
                                        font.family: "JetBrainsMono Nerd Font"
                                        font.pixelSize: Math.round(11 * shell.fontScale)
                                        font.weight: Font.Black
                                        elide: Text.ElideRight
                                    }

                                    Text {
                                        text: component.muted ? "Muted" : "Audio output"
                                        color: component.muted ? shell.error : shell.muted
                                        font.family: "JetBrainsMono Nerd Font"
                                        font.pixelSize: Math.round(8 * shell.fontScale)
                                        font.weight: Font.Bold
                                    }
                                }

                                Text {
                                    text: Math.round(component.volume * 100) + "%"
                                    color: shell.uiPalette[4]
                                    font.family: "JetBrainsMono Nerd Font"
                                    font.pixelSize: Math.round(16 * shell.fontScale)
                                    font.weight: Font.Black
                                }
                            }

                            Rectangle {
                                id: volumeTrack
                                Layout.fillWidth: true
                                Layout.preferredHeight: 12
                                radius: Math.min(shell.controlRadius, 6)
                                color: shell.surfaceHover
                                clip: true

                                Rectangle {
                                    width: parent.width * component.volume
                                    height: parent.height
                                    radius: parent.radius
                                    color: component.muted
                                        ? shell.error
                                        : shell.uiPalette[4]

                                    Behavior on width {
                                        NumberAnimation {
                                            duration: 90
                                            easing.type: Easing.OutCubic
                                        }
                                    }
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onPressed: mouse =>
                                        component.setVolume(mouse.x / width)
                                    onPositionChanged: mouse => {
                                        if (pressed) {
                                            component.setVolume(mouse.x / width)
                                        }
                                    }
                                }
                            }
                        }
                    }

                    GridLayout {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 176
                        columns: 2
                        rowSpacing: 8
                        columnSpacing: 8

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            radius: shell.cardRadius
                            color: Networking.wifiEnabled
                                ? shell.uiPalette[3]
                                : (wifiMouse.containsMouse ? shell.surfaceHover : shell.surface)
                            border.width: Networking.wifiEnabled ? 0 : shell.borderWidth
                            border.color: shell.border

                            RowLayout {
                                anchors {
                                    fill: parent
                                    margins: 13
                                }
                                spacing: 10

                                Text {
                                    text: "󰖩"
                                    color: Networking.wifiEnabled ? shell.ink : shell.text
                                    font.family: "JetBrainsMono Nerd Font"
                                    font.pixelSize: Math.round(20 * shell.fontScale)
                                }

                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 2

                                    Text {
                                        text: "WI-FI"
                                        color: Networking.wifiEnabled ? shell.ink : shell.textStrong
                                        font.family: "JetBrainsMono Nerd Font"
                                        font.pixelSize: Math.round(11 * shell.fontScale)
                                        font.weight: Font.Black
                                    }

                                    Text {
                                        Layout.fillWidth: true
                                        text: component.networkLabel
                                        color: Networking.wifiEnabled ? shell.ink : shell.muted
                                        opacity: 0.78
                                        font.family: "JetBrainsMono Nerd Font"
                                        font.pixelSize: Math.round(8 * shell.fontScale)
                                        font.weight: Font.Bold
                                        elide: Text.ElideRight
                                    }
                                }
                            }

                            MouseArea {
                                id: wifiMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: Networking.wifiEnabled = !Networking.wifiEnabled
                            }
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            radius: shell.cardRadius
                            color:
                                component.bluetoothAdapter !== null
                                && component.bluetoothAdapter.enabled
                                    ? shell.uiPalette[5]
                                    : (bluetoothMouse.containsMouse ? shell.surfaceHover : shell.surface)
                            border.width:
                                component.bluetoothAdapter !== null
                                && component.bluetoothAdapter.enabled
                                    ? 0
                                    : shell.borderWidth
                            border.color: shell.border

                            RowLayout {
                                anchors {
                                    fill: parent
                                    margins: 13
                                }
                                spacing: 10

                                Text {
                                    text: "󰂯"
                                    color:
                                        component.bluetoothAdapter !== null
                                        && component.bluetoothAdapter.enabled
                                            ? shell.ink
                                            : shell.text
                                    font.family: "JetBrainsMono Nerd Font"
                                    font.pixelSize: Math.round(20 * shell.fontScale)
                                }

                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 2

                                    Text {
                                        text: "BLUETOOTH"
                                        color:
                                            component.bluetoothAdapter !== null
                                            && component.bluetoothAdapter.enabled
                                                ? shell.ink
                                                : shell.textStrong
                                        font.family: "JetBrainsMono Nerd Font"
                                        font.pixelSize: Math.round(11 * shell.fontScale)
                                        font.weight: Font.Black
                                    }

                                    Text {
                                        text: component.bluetoothLabel
                                        color:
                                            component.bluetoothAdapter !== null
                                            && component.bluetoothAdapter.enabled
                                                ? shell.ink
                                                : shell.muted
                                        opacity: 0.78
                                        font.family: "JetBrainsMono Nerd Font"
                                        font.pixelSize: Math.round(8 * shell.fontScale)
                                        font.weight: Font.Bold
                                    }
                                }
                            }

                            MouseArea {
                                id: bluetoothMouse
                                anchors.fill: parent
                                enabled: component.bluetoothAdapter !== null
                                hoverEnabled: true
                                cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                                onClicked:
                                    component.bluetoothAdapter.enabled =
                                        !component.bluetoothAdapter.enabled
                            }
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            radius: shell.cardRadius
                            color: component.idleInhibit
                                ? shell.uiPalette[2]
                                : (awakeMouse.containsMouse ? shell.surfaceHover : shell.surface)
                            border.width: component.idleInhibit ? 0 : shell.borderWidth
                            border.color: shell.border

                            RowLayout {
                                anchors {
                                    fill: parent
                                    margins: 13
                                }
                                spacing: 10

                                Text {
                                    text: "󰛨"
                                    color: component.idleInhibit ? shell.ink : shell.text
                                    font.family: "JetBrainsMono Nerd Font"
                                    font.pixelSize: Math.round(20 * shell.fontScale)
                                }

                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 2

                                    Text {
                                        text: "AWAKE"
                                        color: component.idleInhibit ? shell.ink : shell.textStrong
                                        font.family: "JetBrainsMono Nerd Font"
                                        font.pixelSize: Math.round(11 * shell.fontScale)
                                        font.weight: Font.Black
                                    }

                                    Text {
                                        text: component.idleInhibit ? "Enabled" : "Disabled"
                                        color: component.idleInhibit ? shell.ink : shell.muted
                                        opacity: 0.78
                                        font.family: "JetBrainsMono Nerd Font"
                                        font.pixelSize: Math.round(8 * shell.fontScale)
                                        font.weight: Font.Bold
                                    }
                                }
                            }

                            MouseArea {
                                id: awakeMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: component.idleInhibit = !component.idleInhibit
                            }
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            radius: shell.cardRadius
                            color: shell.doNotDisturb
                                ? shell.uiPalette[0]
                                : (dndMouse.containsMouse ? shell.surfaceHover : shell.surface)
                            border.width: shell.doNotDisturb ? 0 : shell.borderWidth
                            border.color: shell.border

                            RowLayout {
                                anchors {
                                    fill: parent
                                    margins: 13
                                }
                                spacing: 10

                                Text {
                                    text: "󰂛"
                                    color: shell.doNotDisturb ? shell.ink : shell.text
                                    font.family: "JetBrainsMono Nerd Font"
                                    font.pixelSize: Math.round(20 * shell.fontScale)
                                }

                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 2

                                    Text {
                                        text: "DO NOT DISTURB"
                                        color: shell.doNotDisturb ? shell.ink : shell.textStrong
                                        font.family: "JetBrainsMono Nerd Font"
                                        font.pixelSize: Math.round(10 * shell.fontScale)
                                        font.weight: Font.Black
                                    }

                                    Text {
                                        text: shell.doNotDisturb ? "Enabled" : "Disabled"
                                        color: shell.doNotDisturb ? shell.ink : shell.muted
                                        opacity: 0.78
                                        font.family: "JetBrainsMono Nerd Font"
                                        font.pixelSize: Math.round(8 * shell.fontScale)
                                        font.weight: Font.Bold
                                    }
                                }
                            }

                            MouseArea {
                                id: dndMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: shell.doNotDisturb = !shell.doNotDisturb
                            }
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 76
                        color: shell.surface
                        radius: shell.cardRadius
                        border.width: shell.borderWidth
                        border.color: shell.border

                        RowLayout {
                            anchors {
                                fill: parent
                                margins: 8
                            }
                            spacing: 7

                            Rectangle {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                radius: shell.controlRadius
                                color: lockMouse.containsMouse
                                    ? shell.uiPalette[4]
                                    : shell.backgroundAlt

                                Text {
                                    anchors.centerIn: parent
                                    text: "󰌾  LOCK"
                                    color: lockMouse.containsMouse ? shell.ink : shell.text
                                    font.family: "JetBrainsMono Nerd Font"
                                    font.pixelSize: Math.round(9 * shell.fontScale)
                                    font.weight: Font.Black
                                }

                                MouseArea {
                                    id: lockMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        component.closePanel()
                                        Hyprland.dispatch("exec hyprlock")
                                    }
                                }
                            }

                            Rectangle {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                radius: shell.controlRadius
                                color: component.pendingAction === "logout"
                                    ? shell.uiPalette[1]
                                    : (logoutMouse.containsMouse ? shell.surfaceHover : shell.backgroundAlt)

                                Text {
                                    anchors.centerIn: parent
                                    text: component.pendingAction === "logout"
                                        ? "CONFIRM"
                                        : "󰍃  LOG OUT"
                                    color: component.pendingAction === "logout" ? shell.ink : shell.text
                                    font.family: "JetBrainsMono Nerd Font"
                                    font.pixelSize: Math.round(9 * shell.fontScale)
                                    font.weight: Font.Black
                                }

                                MouseArea {
                                    id: logoutMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: component.requestAction("logout")
                                }
                            }

                            Rectangle {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                radius: shell.controlRadius
                                color: component.pendingAction === "reboot"
                                    ? shell.uiPalette[2]
                                    : (rebootMouse.containsMouse ? shell.surfaceHover : shell.backgroundAlt)

                                Text {
                                    anchors.centerIn: parent
                                    text: component.pendingAction === "reboot"
                                        ? "CONFIRM"
                                        : "󰜉  RESTART"
                                    color: component.pendingAction === "reboot" ? shell.ink : shell.text
                                    font.family: "JetBrainsMono Nerd Font"
                                    font.pixelSize: Math.round(9 * shell.fontScale)
                                    font.weight: Font.Black
                                }

                                MouseArea {
                                    id: rebootMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: component.requestAction("reboot")
                                }
                            }

                            Rectangle {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                radius: shell.controlRadius
                                color: component.pendingAction === "shutdown"
                                    ? shell.error
                                    : (shutdownMouse.containsMouse ? shell.surfaceHover : shell.backgroundAlt)

                                Text {
                                    anchors.centerIn: parent
                                    text: component.pendingAction === "shutdown"
                                        ? "CONFIRM"
                                        : "󰐥  POWER"
                                    color: component.pendingAction === "shutdown" ? shell.ink : shell.text
                                    font.family: "JetBrainsMono Nerd Font"
                                    font.pixelSize: Math.round(9 * shell.fontScale)
                                    font.weight: Font.Black
                                }

                                MouseArea {
                                    id: shutdownMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: component.requestAction("shutdown")
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

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

    property bool networkOnline: {
        var devices = Networking.devices.values

        for (var index = 0; index < devices.length; index++) {
            if (devices[index] && devices[index].connected) {
                return true
            }
        }

        return false
    }

    property string networkLabel: {
        var devices = Networking.devices.values

        for (var deviceIndex = 0; deviceIndex < devices.length; deviceIndex++) {
            var device = devices[deviceIndex]

            if (!device) {
                continue
            }

            var networks = device.networks.values

            for (var networkIndex = 0; networkIndex < networks.length; networkIndex++) {
                var network = networks[networkIndex]

                if (network && network.connected) {
                    return (network.name || "CONNECTED").toUpperCase()
                }
            }

            if (device.connected) {
                return (device.name || "WIRED LINK").toUpperCase()
            }
        }

        return Networking.wifiEnabled
            ? "NO ACTIVE LINK"
            : "RADIO OFF"
    }

    property int connectedBluetoothCount:
        Bluetooth.devices.values.length

    property string bluetoothLabel:
        bluetoothAdapter === null
            ? "NO ADAPTER"
            : !bluetoothAdapter.enabled
                ? "RADIO OFF"
                : connectedBluetoothCount > 0
                    ? connectedBluetoothCount + " CONNECTED"
                    : "READY"

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

                width: 468
                height: 510

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
                            ? shell.barHeight + 28
                            : 0
                    bottomMargin:
                        shell.barPosition === "BOTTOM"
                            ? shell.barHeight + 28
                            : 0
                }

                color: shell.background
                radius: shell.panelRadius
                border.width: shell.borderWidth
                border.color: shell.border
                clip: true

                MouseArea {
                    anchors.fill: parent
                }

                Row {
                    anchors {
                        top: parent.top
                        left: parent.left
                        right: parent.right
                    }

                    height: 5

                    Repeater {
                        model: 7

                        Rectangle {
                            required property int index
                            width: panel.width / 7
                            height: 5
                            color: shell.uiPalette[index]
                        }
                    }
                }

                ColumnLayout {
                    anchors {
                        fill: parent
                        topMargin: 20
                        bottomMargin: 18
                        leftMargin: 18
                        rightMargin: 18
                    }

                    spacing: 12

                    RowLayout {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 48

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 2

                            Text {
                                text: "CHROMA//CONTROL"
                                color: shell.textStrong
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: Math.round(17 * shell.fontScale)
                                font.weight: Font.Black
                                font.letterSpacing: 1
                            }

                            Text {
                                text: "SYSTEM INTERFACE // " + shell.themeName
                                color: shell.uiPalette[0]
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: Math.round(8 * shell.fontScale)
                                font.weight: Font.Black
                                font.letterSpacing: 1.6
                            }
                        }

                        Rectangle {
                            width: 38
                            height: 38
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
                                font.pixelSize: Math.round(22 * shell.fontScale)
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
                        Layout.preferredHeight: 132
                        color: shell.backgroundAlt
                        radius: shell.panelRadius
                        border.width: shell.borderWidth
                        border.color: shell.surfaceHover

                        ColumnLayout {
                            anchors {
                                fill: parent
                                margins: 14
                            }

                            spacing: 11

                            RowLayout {
                                Layout.fillWidth: true

                                Rectangle {
                                    Layout.preferredWidth: 42
                                    Layout.preferredHeight: 42
                                    radius: shell.controlRadius
                                    color: component.muted
                                        ? shell.uiPalette[0]
                                        : shell.uiPalette[5]

                                    Text {
                                        anchors.centerIn: parent
                                        text: component.muted ? "×" : "♪"
                                        color: shell.ink
                                        font.pixelSize: Math.round(20 * shell.fontScale)
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
                                    spacing: 1

                                    Text {
                                        Layout.fillWidth: true
                                        text: component.sink !== null
                                            ? (
                                                component.sink.description
                                                || component.sink.nickname
                                                || "DEFAULT OUTPUT"
                                            ).toUpperCase()
                                            : "NO AUDIO OUTPUT"
                                        color: shell.text
                                        font.family: "JetBrainsMono Nerd Font"
                                        font.pixelSize: Math.round(11 * shell.fontScale)
                                        font.weight: Font.Black
                                        elide: Text.ElideRight
                                    }

                                    Text {
                                        text: component.muted
                                            ? "OUTPUT MUTED"
                                            : "PIPEWIRE OUTPUT"
                                        color: component.muted
                                            ? shell.uiPalette[0]
                                            : shell.muted
                                        font.family: "JetBrainsMono Nerd Font"
                                        font.pixelSize: Math.round(8 * shell.fontScale)
                                        font.weight: Font.Bold
                                        font.letterSpacing: 1.3
                                    }
                                }

                                Text {
                                    text: Math.round(component.volume * 100) + "%"
                                    color: shell.uiPalette[5]
                                    font.family: "JetBrainsMono Nerd Font"
                                    font.pixelSize: Math.round(18 * shell.fontScale)
                                    font.weight: Font.Black
                                }
                            }

                            Rectangle {
                                id: volumeTrack
                                Layout.fillWidth: true
                                Layout.preferredHeight: 16
                                radius: shell.controlRadius
                                color: shell.surfaceHover
                                clip: true

                                Rectangle {
                                    width: parent.width * component.volume
                                    height: parent.height
                                    radius: shell.controlRadius
                                    color: component.muted
                                        ? shell.uiPalette[0]
                                        : shell.uiPalette[5]

                                    Behavior on width {
                                        NumberAnimation {
                                            duration: 90
                                            easing.type: Easing.OutCubic
                                        }
                                    }
                                }

                                Row {
                                    anchors.fill: parent
                                    spacing: 14

                                    Repeater {
                                        model: 24

                                        Rectangle {
                                            required property int index
                                            width: 2
                                            height: parent.height
                                            color: shell.background
                                            opacity: 0.42
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

                    RowLayout {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 112
                        spacing: 8

                        Rectangle {
                            id: networkTile
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            radius: shell.panelRadius
                            color: Networking.wifiEnabled
                                ? shell.uiPalette[4]
                                : shell.surface
                            border.width: Networking.wifiEnabled ? 0 : shell.borderWidth
                            border.color: shell.border

                            ColumnLayout {
                                anchors {
                                    fill: parent
                                    margins: 12
                                }

                                Text {
                                    text: "NET"
                                    color: Networking.wifiEnabled
                                        ? shell.ink
                                        : shell.uiPalette[4]
                                    font.family: "JetBrainsMono Nerd Font"
                                    font.pixelSize: Math.round(19 * shell.fontScale)
                                    font.weight: Font.Black
                                }

                                Item { Layout.fillHeight: true }

                                Text {
                                    Layout.fillWidth: true
                                    text: component.networkLabel
                                    color: Networking.wifiEnabled
                                        ? shell.ink
                                        : shell.text
                                    font.family: "JetBrainsMono Nerd Font"
                                    font.pixelSize: Math.round(8 * shell.fontScale)
                                    font.weight: Font.Black
                                    elide: Text.ElideRight
                                }

                                Text {
                                    text: Networking.wifiEnabled ? "RADIO ON" : "RADIO OFF"
                                    color: Networking.wifiEnabled
                                        ? shell.surfaceHover
                                        : shell.dim
                                    font.family: "JetBrainsMono Nerd Font"
                                    font.pixelSize: Math.round(7 * shell.fontScale)
                                    font.weight: Font.Bold
                                    font.letterSpacing: 1
                                }
                            }

                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked:
                                    Networking.wifiEnabled = !Networking.wifiEnabled
                            }
                        }

                        Rectangle {
                            id: bluetoothTile
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            radius: shell.panelRadius
                            color:
                                component.bluetoothAdapter !== null
                                && component.bluetoothAdapter.enabled
                                    ? shell.uiPalette[6]
                                    : shell.surface
                            border.width:
                                component.bluetoothAdapter !== null
                                && component.bluetoothAdapter.enabled
                                    ? 0
                                    : 1
                            border.color: shell.border

                            ColumnLayout {
                                anchors {
                                    fill: parent
                                    margins: 12
                                }

                                Text {
                                    text: "BT"
                                    color:
                                        component.bluetoothAdapter !== null
                                        && component.bluetoothAdapter.enabled
                                            ? shell.ink
                                            : shell.uiPalette[6]
                                    font.family: "JetBrainsMono Nerd Font"
                                    font.pixelSize: Math.round(19 * shell.fontScale)
                                    font.weight: Font.Black
                                }

                                Item { Layout.fillHeight: true }

                                Text {
                                    Layout.fillWidth: true
                                    text: component.bluetoothLabel
                                    color:
                                        component.bluetoothAdapter !== null
                                        && component.bluetoothAdapter.enabled
                                            ? shell.ink
                                            : shell.text
                                    font.family: "JetBrainsMono Nerd Font"
                                    font.pixelSize: Math.round(8 * shell.fontScale)
                                    font.weight: Font.Black
                                    elide: Text.ElideRight
                                }

                                Text {
                                    text: "BLUEZ RADIO"
                                    color:
                                        component.bluetoothAdapter !== null
                                        && component.bluetoothAdapter.enabled
                                            ? shell.surfaceHover
                                            : shell.dim
                                    font.family: "JetBrainsMono Nerd Font"
                                    font.pixelSize: Math.round(7 * shell.fontScale)
                                    font.weight: Font.Bold
                                    font.letterSpacing: 1
                                }
                            }

                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                enabled: component.bluetoothAdapter !== null

                                onClicked:
                                    component.bluetoothAdapter.enabled =
                                        !component.bluetoothAdapter.enabled
                            }
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            radius: shell.panelRadius
                            color: component.idleInhibit
                                ? shell.uiPalette[2]
                                : shell.surface
                            border.width: component.idleInhibit ? 0 : shell.borderWidth
                            border.color: shell.border

                            ColumnLayout {
                                anchors {
                                    fill: parent
                                    margins: 12
                                }

                                Text {
                                    text: "AWAKE"
                                    color: component.idleInhibit
                                        ? shell.ink
                                        : shell.uiPalette[2]
                                    font.family: "JetBrainsMono Nerd Font"
                                    font.pixelSize: Math.round(15 * shell.fontScale)
                                    font.weight: Font.Black
                                }

                                Item { Layout.fillHeight: true }

                                Text {
                                    text: component.idleInhibit
                                        ? "INHIBITED"
                                        : "NORMAL"
                                    color: component.idleInhibit
                                        ? shell.ink
                                        : shell.text
                                    font.family: "JetBrainsMono Nerd Font"
                                    font.pixelSize: Math.round(8 * shell.fontScale)
                                    font.weight: Font.Black
                                }

                                Text {
                                    text: "IDLE STATE"
                                    color: component.idleInhibit
                                        ? shell.surfaceHover
                                        : shell.dim
                                    font.family: "JetBrainsMono Nerd Font"
                                    font.pixelSize: Math.round(7 * shell.fontScale)
                                    font.weight: Font.Bold
                                    font.letterSpacing: 1
                                }
                            }

                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked:
                                    component.idleInhibit = !component.idleInhibit
                            }
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 128
                        color: shell.backgroundAlt
                        radius: shell.panelRadius
                        border.width: shell.borderWidth
                        border.color: shell.surfaceHover

                        ColumnLayout {
                            anchors {
                                fill: parent
                                margins: 12
                            }

                            spacing: 9

                            RowLayout {
                                Layout.fillWidth: true

                                Text {
                                    text: "SESSION CONTROL"
                                    color: shell.text
                                    font.family: "JetBrainsMono Nerd Font"
                                    font.pixelSize: Math.round(10 * shell.fontScale)
                                    font.weight: Font.Black
                                    font.letterSpacing: 1.5
                                }

                                Item { Layout.fillWidth: true }

                                Text {
                                    text: component.pendingAction === ""
                                        ? "SAFE MODE"
                                        : "CONFIRM ACTION"
                                    color: component.pendingAction === ""
                                        ? shell.dim
                                        : shell.uiPalette[0]
                                    font.family: "JetBrainsMono Nerd Font"
                                    font.pixelSize: Math.round(8 * shell.fontScale)
                                    font.weight: Font.Black
                                    font.letterSpacing: 1
                                }
                            }

                            RowLayout {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                spacing: 7

                                Rectangle {
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    radius: shell.controlRadius
                                    color: lockMouse.containsMouse
                                        ? shell.uiPalette[4]
                                        : shell.surface
                                    border.width: lockMouse.containsMouse ? 0 : shell.borderWidth
                                    border.color: shell.border

                                    Text {
                                        anchors.centerIn: parent
                                        text: "LOCK"
                                        color: lockMouse.containsMouse
                                            ? shell.ink
                                            : shell.text
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
                                        : logoutMouse.containsMouse
                                            ? shell.surfaceHover
                                            : shell.surface
                                    border.width: component.pendingAction === "logout" ? 0 : shell.borderWidth
                                    border.color: shell.border

                                    Text {
                                        anchors.centerIn: parent
                                        text: component.pendingAction === "logout"
                                            ? "CONFIRM"
                                            : "LOGOUT"
                                        color: component.pendingAction === "logout"
                                            ? shell.ink
                                            : shell.text
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
                                        : rebootMouse.containsMouse
                                            ? shell.surfaceHover
                                            : shell.surface
                                    border.width: component.pendingAction === "reboot" ? 0 : shell.borderWidth
                                    border.color: shell.border

                                    Text {
                                        anchors.centerIn: parent
                                        text: component.pendingAction === "reboot"
                                            ? "CONFIRM"
                                            : "REBOOT"
                                        color: component.pendingAction === "reboot"
                                            ? shell.ink
                                            : shell.text
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
                                        ? shell.uiPalette[0]
                                        : shutdownMouse.containsMouse
                                            ? shell.surfaceHover
                                            : shell.surface
                                    border.width: component.pendingAction === "shutdown" ? 0 : shell.borderWidth
                                    border.color: shell.border

                                    Text {
                                        anchors.centerIn: parent
                                        text: component.pendingAction === "shutdown"
                                            ? "CONFIRM"
                                            : "POWER"
                                        color: component.pendingAction === "shutdown"
                                            ? shell.ink
                                            : shell.text
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

                    RowLayout {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 22

                        Rectangle {
                            width: 8
                            height: 8
                            radius: shell.controlRadius
                            color: component.networkOnline
                                ? shell.uiPalette[3]
                                : shell.uiPalette[0]
                        }

                        Text {
                            text: component.networkOnline
                                ? "SYSTEM LINK ONLINE"
                                : "SYSTEM LINK LIMITED"
                            color: shell.muted
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: Math.round(8 * shell.fontScale)
                            font.weight: Font.Black
                            font.letterSpacing: 1.1
                        }

                        Item { Layout.fillWidth: true }

                        Text {
                            text: "CLICK OUTSIDE TO CLOSE"
                            color: shell.dim
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: Math.round(7 * shell.fontScale)
                            font.weight: Font.Bold
                            font.letterSpacing: 1
                        }
                    }
                }
            }
        }
    }
}

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pipewire

Scope {
    id: component

    required property var shell

    property var sink: Pipewire.defaultAudioSink
    property var audio:
        sink !== null && sink.audio !== null
            ? sink.audio
            : null

    property bool armed: false
    property bool showing: false
    property string mode: "VOLUME"
    property int value: 0
    property bool muted: false

    function reveal(kind, amount, isMuted) {
        mode = kind
        value = Math.max(0, Math.min(100, Math.round(amount)))
        muted = isMuted === true
        showing = true
        hideTimer.restart()
    }

    function showVolume(amount) {
        reveal("VOLUME", amount, false)
    }

    function showBrightness(amount) {
        reveal("BRIGHTNESS", amount, false)
    }

    function showMute(isMuted) {
        var amount = audio !== null
            ? Math.round(audio.volume * 100)
            : value
        reveal(isMuted ? "MUTED" : "VOLUME", amount, isMuted)
    }

    readonly property color accent:
        muted
            ? shell.uiPalette[0]
            : mode === "BRIGHTNESS"
                ? shell.uiPalette[2]
                : shell.uiPalette[5]

    PwObjectTracker {
        objects: [ Pipewire.defaultAudioSink ]
    }

    Timer {
        id: armTimer
        interval: 1400
        repeat: false
        running: true
        onTriggered: component.armed = true
    }

    Timer {
        id: hideTimer
        interval: Math.round(shell.osdDuration * 1000)
        repeat: false
        onTriggered: component.showing = false
    }

    Connections {
        target: component.audio
        enabled: component.audio !== null

        function onVolumeChanged() {
            if (component.armed) {
                component.showVolume(component.audio.volume * 100)
            }
        }

        function onMutedChanged() {
            if (component.armed) {
                component.showMute(component.audio.muted)
            }
        }
    }

    IpcHandler {
        target: "osd"

        function volume(amount: int): void {
            component.showVolume(amount)
        }

        function brightness(amount: int): void {
            component.showBrightness(amount)
        }

        function mute(isMuted: bool): void {
            component.showMute(isMuted)
        }
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: osdWindow

            required property var modelData

            screen: modelData
            visible:
                modelData.name === shell.resolvedBarMonitor
                && shell.showOsd
                && component.showing

            anchors {
                left: true
                right: true
                top: shell.osdPosition === "TOP"
                bottom: shell.osdPosition !== "TOP"
            }

            margins {
                top: shell.osdPosition === "TOP" ? 28 : 0
                bottom: shell.osdPosition === "BOTTOM" ? shell.barHeight + 28 : 0
            }
            implicitHeight: 84
            exclusiveZone: 0
            aboveWindows: true
            color: "transparent"

            mask: Region { item: card }

            Rectangle {
                id: card

                width: 370
                height: 72
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top:
                    shell.osdPosition === "TOP"
                        ? parent.top
                        : undefined
                anchors.bottom:
                    shell.osdPosition === "BOTTOM"
                        ? parent.bottom
                        : undefined

                color: shell.background
                radius: shell.panelRadius
                border.width: shell.borderWidth
                border.color: component.accent
                clip: true

                Rectangle {
                    anchors {
                        left: parent.left
                        top: parent.top
                        bottom: parent.bottom
                    }
                    width: 7
                    color: component.accent
                }

                RowLayout {
                    anchors {
                        fill: parent
                        leftMargin: 18
                        rightMargin: 14
                        topMargin: 10
                        bottomMargin: 10
                    }
                    spacing: 13

                    Rectangle {
                        Layout.preferredWidth: 42
                        Layout.fillHeight: true
                        radius: shell.controlRadius
                        color: component.accent

                        Text {
                            anchors.centerIn: parent
                            text: component.mode === "BRIGHTNESS"
                                ? "☀"
                                : component.muted
                                    ? "×"
                                    : "♪"
                            color: shell.ink
                            font.pixelSize: Math.round(20 * shell.fontScale)
                            font.weight: Font.Black
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 6

                        RowLayout {
                            Layout.fillWidth: true

                            Text {
                                text: component.mode
                                color: shell.text
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: Math.round(10 * shell.fontScale)
                                font.weight: Font.Black
                                font.letterSpacing: 1.3
                            }

                            Item { Layout.fillWidth: true }

                            Text {
                                text: component.value + "%"
                                color: component.accent
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: Math.round(14 * shell.fontScale)
                                font.weight: Font.Black
                            }
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 12
                            color: shell.surfaceHover
                            radius: shell.controlRadius
                            clip: true

                            Rectangle {
                                width: parent.width * component.value / 100
                                height: parent.height
                                radius: shell.controlRadius
                                color: component.accent

                                Behavior on width {
                                    NumberAnimation {
                                        duration: 100
                                        easing.type: Easing.OutCubic
                                    }
                                }
                            }

                            Row {
                                anchors.fill: parent
                                spacing: 12
                                Repeater {
                                    model: 28
                                    Rectangle {
                                        required property int index
                                        width: 2
                                        height: parent.height
                                        color: shell.background
                                        opacity: 0.45
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

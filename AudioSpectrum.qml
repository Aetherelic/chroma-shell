import QtQuick
import Quickshell
import Quickshell.Io

Scope {
    id: spectrum

    property int barCount: 28
    property bool enabled: true
    property real sensitivity: 1.0
    property real smoothing: 0.28
    property bool available: false
    property var values: [
        0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0
    ]

    function reset() {
        var next = []

        for (var index = 0; index < barCount; index++) {
            next.push(0)
        }

        values = next
        available = false
    }

    function consumeFrame(frame) {
        var text = String(frame).trim()

        if (text.length === 0) {
            return
        }

        var raw = text.split(";")
        var parsed = []

        for (var index = 0; index < raw.length; index++) {
            var number = Number(raw[index])

            if (!isNaN(number)) {
                parsed.push(
                    Math.max(
                        0,
                        Math.min(1, number / 1000 * spectrum.sensitivity)
                    )
                )
            }
        }

        if (parsed.length === 0) {
            return
        }

        var previous = values
        var next = []

        for (var bar = 0; bar < barCount; bar++) {
            var sourceIndex = Math.min(
                parsed.length - 1,
                Math.floor(bar * parsed.length / barCount)
            )

            var oldValue = previous.length > bar
                ? previous[bar]
                : 0

            var target = parsed[sourceIndex]
            var retention = Math.max(0.05, Math.min(0.85, spectrum.smoothing))
            next.push(oldValue * retention + target * (1 - retention))
        }

        values = next
        available = true
    }

    function start() {
        if (enabled && !cavaProcess.running) {
            cavaProcess.running = true
        }
    }


    onBarCountChanged: {
        reset()
    }

    onEnabledChanged: {
        if (enabled) {
            start()
        } else {
            retryTimer.stop()
            cavaProcess.running = false
            reset()
        }
    }

    Component.onCompleted:
        start()

    Process {
        id: cavaProcess

        command: [
            "bash",
            Quickshell.shellPath("chroma-cava"),
            Quickshell.shellPath("cava.conf")
        ]

        stdout: SplitParser {
            onRead: frame => spectrum.consumeFrame(frame)
        }

        onExited: {
            spectrum.available = false

            if (spectrum.enabled) {
                retryTimer.restart()
            }
        }
    }

    Timer {
        id: retryTimer

        interval: 2500
        repeat: false

        onTriggered:
            spectrum.start()
    }
}

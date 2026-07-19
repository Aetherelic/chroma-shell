import QtQuick
import Quickshell
import Quickshell.Io

Scope {
    id: stats

    property bool enabled: true
    property real cpuUsage: 0
    property real gpuUsage: 0
    property real memoryUsage: 0
    property real cpuTemperature: -1
    property real gpuTemperature: -1
    property string gpuName: "GPU"
    property bool available: false

    function refresh() {
        if (!statsProcess.running) {
            statsProcess.running = true
        }
    }

    Process {
        id: statsProcess
        command: [
            "bash",
            Quickshell.shellPath("backend/chroma-widget-stats")
        ]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    var data = JSON.parse(text)
                    stats.cpuUsage = Number(data.cpu || 0)
                    stats.gpuUsage = Number(data.gpu || 0)
                    stats.memoryUsage = Number(data.memory || 0)
                    stats.cpuTemperature = Number(data.cpuTemperature || -1)
                    stats.gpuTemperature = Number(data.gpuTemperature || -1)
                    stats.gpuName = String(data.gpuName || "GPU")
                    stats.available = true
                } catch (error) {
                    stats.available = false
                }
            }
        }
    }

    Timer {
        interval: 2200
        running: stats.enabled
        repeat: true
        triggeredOnStart: true
        onTriggered: stats.refresh()
    }

    onEnabledChanged: {
        if (enabled) {
            refresh()
        }
    }
}

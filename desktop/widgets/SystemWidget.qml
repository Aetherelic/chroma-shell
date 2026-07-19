import QtQuick
import QtQuick.Layouts

Item {
    id: widget
    required property var shell
    required property var widgetData

    readonly property var stats: shell.systemStats
    readonly property string contentFont:
        String(widgetData.settings.fontFamily || "JetBrainsMono Nerd Font")
    readonly property real contentScale:
        Math.max(0.70, Math.min(1.80, Number(widgetData.settings.fontScale || 1.0)))
    readonly property var rows: [
        { label: "CPU", value: stats.cpuUsage, accent: shell.uiPalette[0], temp: stats.cpuTemperature },
        { label: "GPU", value: stats.gpuUsage, accent: shell.uiPalette[4], temp: stats.gpuTemperature },
        { label: "RAM", value: stats.memoryUsage, accent: shell.uiPalette[3], temp: -1 }
    ]

    ColumnLayout {
        anchors.fill: parent
        spacing: Math.max(7, Math.round(10 * widget.contentScale))

        Text {
            Layout.fillWidth: true
            text: "SYSTEM"
            color: shell.textStrong
            font.family: widget.contentFont
            font.pixelSize: Math.round(9 * shell.fontScale * widget.contentScale)
            font.weight: Font.Black
            font.letterSpacing: 1.1
        }

        Repeater {
            model: widget.rows

            ColumnLayout {
                required property var modelData
                Layout.fillWidth: true
                spacing: 5

                RowLayout {
                    Layout.fillWidth: true

                    Text {
                        text: modelData.label
                        color: modelData.accent
                        font.family: widget.contentFont
                        font.pixelSize: Math.round(8 * shell.fontScale * widget.contentScale)
                        font.weight: Font.Black
                    }

                    Item { Layout.fillWidth: true }

                    Text {
                        text: Math.round(modelData.value) + "%"
                            + (modelData.temp >= 0
                                && widgetData.settings.temperature !== false
                                ? "  ·  " + Math.round(modelData.temp) + "°C"
                                : "")
                        color: shell.text
                        font.family: widget.contentFont
                        font.pixelSize: Math.round(8 * shell.fontScale * widget.contentScale)
                        font.weight: Font.Bold
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: Math.max(7, Math.round(9 * widget.contentScale))
                    color: shell.background
                    radius: shell.microRadius
                    clip: true

                    Rectangle {
                        width: parent.width * Math.max(0, Math.min(1, modelData.value / 100))
                        height: parent.height
                        color: modelData.accent
                        radius: parent.radius

                        Behavior on width {
                            NumberAnimation {
                                duration: 260
                                easing.type: Easing.OutCubic
                            }
                        }
                    }
                }
            }
        }

        Item { Layout.fillHeight: true }
    }
}

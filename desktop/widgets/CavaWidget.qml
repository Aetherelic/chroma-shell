import QtQuick
import QtQuick.Layouts
import "../.." as Chroma

Item {
    id: widget
    required property var shell
    required property var widgetData

    readonly property string contentFont:
        String(widgetData.settings.fontFamily || "JetBrainsMono Nerd Font")
    readonly property real contentScale:
        Math.max(0.70, Math.min(1.80, Number(widgetData.settings.fontScale || 1.0)))

    ColumnLayout {
        anchors.fill: parent
        spacing: 8

        Text {
            Layout.fillWidth: true
            text: "SPECTRUM"
            color: shell.textStrong
            font.family: widget.contentFont
            font.pixelSize: Math.round(9 * shell.fontScale * widget.contentScale)
            font.weight: Font.Black
            font.letterSpacing: 1.1
        }

        Chroma.SpectrumBars {
            Layout.fillWidth: true
            Layout.fillHeight: true
            values: shell.spectrumValues
            palette: shell.visualizerPalette
            active: shell.spectrumAvailable
            barWidth: Math.max(
                3,
                Math.min(
                    12,
                    (width - (shell.spectrumValues.length - 1) * 4)
                    / Math.max(1, shell.spectrumValues.length)
                )
            )
            barSpacing: 4
            minimumBarHeight: 3
        }
    }
}

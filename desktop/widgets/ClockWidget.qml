import QtQuick
import QtQuick.Layouts

Item {
    id: widget
    required property var shell
    required property var widgetData

    readonly property string contentFont:
        String(widgetData.settings.fontFamily || "JetBrainsMono Nerd Font")
    readonly property real contentScale:
        Math.max(0.70, Math.min(1.80, Number(widgetData.settings.fontScale || 1.0)))
    readonly property bool showSeconds: widgetData.settings.seconds === true

    ColumnLayout {
        anchors.fill: parent
        spacing: Math.max(3, Math.round(7 * widget.contentScale))

        Item { Layout.fillHeight: true }

        Text {
            Layout.fillWidth: true
            text: Qt.formatDateTime(
                shell.now,
                shell.clockFormat === "12H"
                    ? (widget.showSeconds ? "hh:mm:ss AP" : "hh:mm AP")
                    : (widget.showSeconds ? "HH:mm:ss" : "HH:mm")
            )
            color: shell.textStrong
            font.family: widget.contentFont
            font.pixelSize: Math.round(
                Math.min(widget.width * 0.18, widget.height * 0.43)
                * widget.contentScale
            )
            font.weight: Font.Black
            font.letterSpacing: 1.2
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            style: Text.Outline
            styleColor: "#58000000"
            elide: Text.ElideRight
        }

        Text {
            visible: widgetData.settings.date !== false
            Layout.fillWidth: true
            text: Qt.formatDateTime(shell.now, "dddd  dd MMMM yyyy").toUpperCase()
            color: shell.muted
            font.family: widget.contentFont
            font.pixelSize: Math.round(
                Math.min(widget.width * 0.034, widget.height * 0.095)
                * widget.contentScale
            )
            font.weight: Font.Bold
            font.letterSpacing: 1
            horizontalAlignment: Text.AlignHCenter
            style: Text.Outline
            styleColor: "#44000000"
            elide: Text.ElideRight
        }

        Item { Layout.fillHeight: true }
    }
}

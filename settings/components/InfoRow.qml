import QtQuick
import QtQuick.Layouts

RowLayout {
    id: row

    required property var shell

    property string label: "LABEL"
    property string value: "—"
    property color valueColor: shell.text

    implicitHeight: 24
    spacing: 14

    Text {
        Layout.preferredWidth: 180
        text: row.label.toUpperCase()
        color: shell.muted
        font.family: "JetBrainsMono Nerd Font"
        font.pixelSize: Math.round(8 * shell.fontScale)
        font.weight: Font.Bold
        font.letterSpacing: 0.8
    }

    Text {
        Layout.fillWidth: true
        text: row.value
        color: row.valueColor
        font.family: "JetBrainsMono Nerd Font"
        font.pixelSize: Math.round(9 * shell.fontScale)
        font.weight: Font.Bold
        elide: Text.ElideRight
        horizontalAlignment: Text.AlignRight
    }
}

import QtQuick
import QtQuick.Layouts

ColumnLayout {
    id: header

    required property var shell

    property string index: "00"
    property string title: "SETTINGS"
    property string subtitle: "CHROMA SYSTEM CONFIGURATION"

    spacing: 0

    RowLayout {
        Layout.fillWidth: true

        Text {
            text: header.index
            color: shell.uiPalette[0]
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: Math.round(10 * shell.fontScale)
            font.weight: Font.Black
            font.letterSpacing: 1
        }

        Rectangle {
            Layout.preferredWidth: 32
            Layout.preferredHeight: 2
            color: shell.uiPalette[0]
        }

        Text {
            Layout.fillWidth: true
            text: header.title.toUpperCase()
            color: shell.textStrong
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: Math.round(22 * shell.fontScale)
            font.weight: Font.Black
            font.letterSpacing: 1.2
        }
    }

}

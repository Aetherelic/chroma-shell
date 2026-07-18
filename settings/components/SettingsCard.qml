import QtQuick
import QtQuick.Layouts

Rectangle {
    id: card

    required property var shell

    property string title: ""
    property string subtitle: ""
    property color accent: shell.uiPalette[4]
    property int padding: shell.panelPadding

    default property alias content: body.data

    implicitHeight: layout.implicitHeight + padding * 2
    color: shell.surface
    border.width: shell.borderWidth
    border.color: shell.border
    radius: shell.cardRadius

    Rectangle {
        anchors {
            left: parent.left
            top: parent.top
            bottom: parent.bottom
        }
        width: 3
        color: card.accent
    }

    ColumnLayout {
        id: layout
        anchors {
            fill: parent
            margins: card.padding
            leftMargin: card.padding + 3
        }
        spacing: 14

        ColumnLayout {
            visible: card.title.length > 0
            Layout.fillWidth: true
            spacing: 0

            Text {
                Layout.fillWidth: true
                text: card.title.toUpperCase()
                color: shell.textStrong
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: Math.round(12 * shell.fontScale)
                font.weight: Font.Black
                font.letterSpacing: 1
            }

        }

        ColumnLayout {
            id: body
            Layout.fillWidth: true
            spacing: 10
        }
    }
}

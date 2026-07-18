import QtQuick
import QtQuick.Layouts

Rectangle {
    id: field

    required property var shell

    property alias text: input.text
    property alias echoMode: input.echoMode
    property string placeholder: ""
    property string prefix: ""

    signal accepted()

    implicitHeight: 42
    implicitWidth: 280

    color: shell.backgroundAlt
    border.width: input.activeFocus ? 2 : 1
    border.color: input.activeFocus ? shell.uiPalette[4] : shell.border
    radius: shell.controlRadius

    RowLayout {
        anchors {
            fill: parent
            leftMargin: 12
            rightMargin: 12
        }
        spacing: 10

        Text {
            visible: field.prefix.length > 0
            text: field.prefix
            color: shell.uiPalette[4]
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: Math.round(10 * shell.fontScale)
            font.weight: Font.Black
        }

        TextInput {
            id: input
            Layout.fillWidth: true
            color: shell.text
            selectionColor: shell.uiPalette[4]
            selectedTextColor: shell.ink
            clip: true
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: Math.round(10 * shell.fontScale)
            verticalAlignment: TextInput.AlignVCenter
            onAccepted: field.accepted()
        }

        Text {
            visible: input.text.length === 0 && !input.activeFocus
            Layout.fillWidth: true
            text: field.placeholder.toUpperCase()
            color: shell.dim
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: Math.round(8 * shell.fontScale)
            font.weight: Font.Bold
            font.letterSpacing: 0.6
        }
    }

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton
        onPressed: {
            mouse.accepted = false
            input.forceActiveFocus()
        }
    }
}

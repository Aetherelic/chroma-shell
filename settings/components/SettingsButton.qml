import QtQuick
import QtQuick.Layouts

Rectangle {
    id: control

    required property var shell

    property string label: "ACTION"
    property string sublabel: ""
    property color accent: shell.uiPalette[4]
    property bool filled: false
    property bool danger: false

    signal clicked()

    implicitWidth: 132
    implicitHeight: sublabel.length > 0 ? 48 : 40

    color: !enabled
        ? shell.surface
        : (filled || pointer.containsMouse)
            ? (danger ? shell.error : accent)
            : shell.surface

    border.width: (filled || pointer.containsMouse) ? 0 : shell.borderWidth
    border.color: shell.border
    radius: shell.controlRadius
    opacity: enabled ? 1 : 0.46

    Behavior on color { ColorAnimation { duration: 130 } }

    ColumnLayout {
        anchors.centerIn: parent
        spacing: 1

        Text {
            Layout.alignment: Qt.AlignHCenter
            text: control.label.toUpperCase()
            color: (control.filled || pointer.containsMouse)
                ? shell.ink
                : shell.text
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: Math.round(10 * shell.fontScale)
            font.weight: Font.Black
            font.letterSpacing: 0.8
        }

        Text {
            visible: control.sublabel.length > 0
            Layout.alignment: Qt.AlignHCenter
            text: control.sublabel.toUpperCase()
            color: (control.filled || pointer.containsMouse)
                ? shell.ink
                : shell.muted
            opacity: 0.72
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: Math.round(8 * shell.fontScale)
            font.weight: Font.Bold
            font.letterSpacing: 0.6
        }
    }

    MouseArea {
        id: pointer
        anchors.fill: parent
        enabled: control.enabled
        hoverEnabled: true
        cursorShape: control.enabled
            ? Qt.PointingHandCursor
            : Qt.ArrowCursor
        onClicked: control.clicked()
    }
}

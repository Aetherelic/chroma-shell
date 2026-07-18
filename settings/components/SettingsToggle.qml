import QtQuick
import QtQuick.Layouts

Item {
    id: control

    required property var shell

    property string label: "SETTING"
    property string description: ""
    property bool checked: false
    property color accent: shell.uiPalette[3]

    signal toggled(bool value)

    implicitHeight: 44
    implicitWidth: 360

    RowLayout {
        anchors.fill: parent
        spacing: 16

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 3

            Text {
                Layout.fillWidth: true
                text: control.label.toUpperCase()
                color: shell.text
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: Math.round(10 * shell.fontScale)
                font.weight: Font.Black
                font.letterSpacing: 0.8
                elide: Text.ElideRight
            }

        }

        Rectangle {
            Layout.preferredWidth: 48
            Layout.preferredHeight: 24
            Layout.alignment: Qt.AlignVCenter
            radius: shell.controlRadius
            color: control.checked ? control.accent : shell.surface
            border.width: control.checked ? 0 : shell.borderWidth
            border.color: shell.borderStrong

            Rectangle {
                width: 16
                height: 16
                y: 4
                x: control.checked ? parent.width - width - 4 : 4
                radius: shell.controlRadius
                color: control.checked ? shell.ink : shell.muted

                Behavior on x {
                    NumberAnimation {
                        duration: 140
                        easing.type: Easing.OutCubic
                    }
                }
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            control.checked = !control.checked
            control.toggled(control.checked)
        }
    }
}

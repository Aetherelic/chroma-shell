import QtQuick
import QtQuick.Layouts

Rectangle {
    id: button

    required property var shell

    implicitWidth: buttonMouse.containsMouse ? 112 : 54
    implicitHeight: 73

    color: shell.themePanelOpen
        ? shell.uiPalette[2]
        : buttonMouse.containsMouse
            ? shell.uiPalette[5]
            : shell.surface

    radius: shell.moduleRadius
    border.width:
        shell.themePanelOpen || buttonMouse.containsMouse
            ? 0
            : 1
    border.color: shell.border

    Behavior on implicitWidth {
        NumberAnimation {
            duration: 170
            easing.type: Easing.OutCubic
        }
    }

    Behavior on color {
        ColorAnimation { duration: 150 }
    }

    RowLayout {
        anchors.centerIn: parent
        spacing: 8

        Grid {
            Layout.preferredWidth: 24
            Layout.preferredHeight: 24
            columns: 2
            spacing: 3

            Repeater {
                model: 4

                Rectangle {
                    required property int index
                    width: 10
                    height: 10
                    radius: shell.controlRadius
                    color: shell.uiPalette[(index * 2) % shell.palette.length]

                    border.width: buttonMouse.containsMouse ? 1 : 0
                    border.color: shell.ink
                }
            }
        }

        Column {
            visible: buttonMouse.containsMouse
            Layout.alignment: Qt.AlignVCenter
            spacing: 1

            Text {
                text: shell.themeName
                color: shell.ink
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: Math.round(9 * shell.fontScale)
                font.weight: Font.Black
                font.letterSpacing: 0.7
            }

            Text {
                text: "THEME ARRAY"
                color: shell.ink
                opacity: 0.62
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: Math.round(7 * shell.fontScale)
                font.weight: Font.Bold
                font.letterSpacing: 1
            }
        }
    }

    MouseArea {
        id: buttonMouse

        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton | Qt.RightButton

        onClicked: function(mouse) {
            if (mouse.button === Qt.RightButton) {
                shell.cycleTheme(1)
                return
            }

            shell.themePanelOpen = !shell.themePanelOpen
        }
    }
}

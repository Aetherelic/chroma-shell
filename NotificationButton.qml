import QtQuick
import QtQuick.Layouts

Rectangle {
    id: button

    required property var shell

    implicitWidth: buttonMouse.containsMouse
        ? shell.utilityHoverWidth
        : shell.utilityWidth
    implicitHeight: shell.barHeight

    color: shell.notificationCenterOpen
        ? shell.uiPalette[0]
        : shell.doNotDisturb
            ? shell.surfaceAlt
            : buttonMouse.containsMouse
                ? shell.uiPalette[6]
                : shell.surface

    radius: shell.moduleRadius
    border.width:
        shell.notificationCenterOpen
        || buttonMouse.containsMouse
            ? 0
            : shell.borderWidth
    border.color: shell.doNotDisturb
        ? shell.uiPalette[2]
        : shell.border

    Behavior on implicitWidth {
        NumberAnimation {
            duration: shell.animationDuration
            easing.type: Easing.OutCubic
        }
    }

    Behavior on color {
        ColorAnimation {
            duration: shell.animationDuration
        }
    }

    RowLayout {
        anchors.centerIn: parent
        spacing: 8

        Item {
            Layout.preferredWidth: 24
            Layout.preferredHeight: 28

            Rectangle {
                anchors {
                    horizontalCenter: parent.horizontalCenter
                    top: parent.top
                    topMargin: 3
                }

                width: 16
                height: 16
                radius: shell.controlRadius

                color: "transparent"
                border.width: 3
                border.color:
                    shell.notificationCenterOpen
                    || buttonMouse.containsMouse
                        ? shell.ink
                        : shell.doNotDisturb
                            ? shell.uiPalette[2]
                            : shell.uiPalette[6]
            }

            Rectangle {
                anchors {
                    horizontalCenter: parent.horizontalCenter
                    bottom: parent.bottom
                    bottomMargin: 3
                }

                width: 7
                height: 3
                radius: shell.controlRadius

                color:
                    shell.notificationCenterOpen
                    || buttonMouse.containsMouse
                        ? shell.ink
                        : shell.doNotDisturb
                            ? shell.uiPalette[2]
                            : shell.uiPalette[0]
            }

            Rectangle {
                visible: shell.notificationCount > 0

                anchors {
                    right: parent.right
                    top: parent.top
                }

                width: 14
                height: 14
                radius: shell.controlRadius
                color: shell.uiPalette[3]

                Text {
                    anchors.centerIn: parent
                    text: shell.notificationCount > 9
                        ? "9+"
                        : shell.notificationCount
                    color: shell.ink
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: Math.round(7 * shell.fontScale)
                    font.weight: Font.Black
                }
            }
        }

        Column {
            visible: buttonMouse.containsMouse
            Layout.alignment: Qt.AlignVCenter
            spacing: 1

            Text {
                text: shell.doNotDisturb
                    ? "DND ACTIVE"
                    : "NOTIFICATIONS"
                color: shell.ink
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: Math.round(9 * shell.fontScale)
                font.weight: Font.Black
                font.letterSpacing: 0.8
            }

            Text {
                text: shell.notificationCount
                    + (shell.notificationCount === 1
                        ? " EVENT"
                        : " EVENTS")
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
                shell.doNotDisturb = !shell.doNotDisturb
                return
            }

            shell.notificationCenterOpen =
                !shell.notificationCenterOpen
        }
    }
}

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.SystemTray
import Quickshell.Widgets

Item {
    id: component

    required property var shell
    required property var hostWindow

    readonly property var trayItems: SystemTray.items.values
    readonly property int shownCount: Math.min(5, trayItems.length)
    readonly property int hiddenCount: Math.max(0, trayItems.length - shownCount)

    implicitWidth: trayItems.length > 0
        ? 12 + shownCount * 36 + (hiddenCount > 0 ? 34 : 0)
        : 0
    implicitHeight: 73
    visible: trayItems.length > 0

    Rectangle {
        anchors.fill: parent
        color: shell.backgroundAlt
        radius: shell.moduleRadius
        border.width: shell.borderWidth
        border.color: shell.border
    }

    Row {
        anchors.centerIn: parent
        spacing: 2

        Repeater {
            model: component.trayItems.slice(0, 5)

            Rectangle {
                id: trayButton

                required property var modelData

                width: 34
                height: 48
                radius: shell.controlRadius

                color: trayMouse.containsMouse
                    ? shell.uiPalette[4]
                    : modelData.status === Status.NeedsAttention
                        ? shell.uiPalette[0]
                        : "transparent"

                Behavior on color {
                    ColorAnimation {
                        duration: 120
                    }
                }

                IconImage {
                    anchors.centerIn: parent
                    implicitSize: 22
                    source: trayButton.modelData.icon
                    asynchronous: true
                    mipmap: true
                    opacity: trayButton.modelData.status === Status.Passive
                        ? 0.58
                        : 1
                }

                MouseArea {
                    id: trayMouse

                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    acceptedButtons:
                        Qt.LeftButton
                        | Qt.RightButton
                        | Qt.MiddleButton

                    function openMenu() {
                        var point = component.hostWindow.mapFromItem(
                            trayButton,
                            trayButton.width / 2,
                            0
                        )

                        trayButton.modelData.display(
                            component.hostWindow,
                            Math.round(point.x),
                            Math.round(point.y)
                        )
                    }

                    onClicked: function(mouse) {
                        if (mouse.button === Qt.MiddleButton) {
                            trayButton.modelData.secondaryActivate()
                            return
                        }

                        if (
                            mouse.button === Qt.RightButton
                            || trayButton.modelData.onlyMenu
                        ) {
                            openMenu()
                            return
                        }

                        trayButton.modelData.activate()
                    }

                    onWheel: function(wheel) {
                        var delta = wheel.angleDelta.y !== 0
                            ? wheel.angleDelta.y
                            : wheel.angleDelta.x

                        trayButton.modelData.scroll(delta, false)
                    }
                }
            }
        }

        Rectangle {
            visible: component.hiddenCount > 0
            width: visible ? 32 : 0
            height: 48
            radius: shell.controlRadius
            color: shell.surface

            Text {
                anchors.centerIn: parent
                text: "+" + component.hiddenCount
                color: shell.uiPalette[2]
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: Math.round(9 * shell.fontScale)
                font.weight: Font.Black
            }
        }
    }
}

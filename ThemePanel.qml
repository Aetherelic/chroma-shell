import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland

Scope {
    id: component

    required property var shell

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: themeWindow

            required property var modelData

            screen: modelData
            visible:
                modelData.name === shell.resolvedBarMonitor
                && shell.themePanelOpen

            anchors {
                left: true
                right: true
                top: true
                bottom: true
            }

            exclusiveZone: 0
            aboveWindows: true
            color: "transparent"

            WlrLayershell.namespace: "chroma-theme-panel"
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

            Rectangle {
                anchors.fill: parent
                color: "#26000000"

                MouseArea {
                    anchors.fill: parent
                    onClicked: shell.themePanelOpen = false
                }
            }

            Rectangle {
                id: panel

                width: Math.min(1080, themeWindow.width - 64)
                height: Math.min(610, themeWindow.height - shell.barHeight - 54)

                anchors {
                    horizontalCenter: parent.horizontalCenter
                    top:
                        shell.barPosition === "TOP"
                            ? parent.top
                            : undefined
                    bottom:
                        shell.barPosition === "BOTTOM"
                            ? parent.bottom
                            : undefined
                    topMargin:
                        shell.barPosition === "TOP"
                            ? shell.barHeight + 22
                            : 0
                    bottomMargin:
                        shell.barPosition === "BOTTOM"
                            ? shell.barHeight + 22
                            : 0
                }

                color: shell.background
                radius: shell.panelRadius
                border.width: shell.borderWidth
                border.color: shell.border
                clip: true

                MouseArea { anchors.fill: parent }

                Row {
                    anchors {
                        left: parent.left
                        right: parent.right
                        top: parent.top
                    }
                    height: 5

                    Repeater {
                        model: shell.spectrumPalette.length

                        Rectangle {
                            required property int index
                            width: panel.width / shell.spectrumPalette.length
                            height: 5
                            color: shell.spectrumPalette[index]
                        }
                    }
                }

                ColumnLayout {
                    anchors {
                        fill: parent
                        topMargin: 20
                        bottomMargin: 16
                        leftMargin: 18
                        rightMargin: 18
                    }
                    spacing: 12

                    RowLayout {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 42

                        Text {
                            Layout.fillWidth: true
                            text: "CHROMA // THEMES"
                            color: shell.textStrong
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: Math.round(17 * shell.fontScale)
                            font.weight: Font.Black
                            font.letterSpacing: 0.7
                        }

                        Text {
                            text: shell.themeName
                            color: shell.uiPalette[0]
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: Math.round(10 * shell.fontScale)
                            font.weight: Font.Black
                        }

                        Rectangle {
                            width: 40
                            height: 40
                            radius: shell.controlRadius
                            color: closeMouse.containsMouse
                                ? shell.uiPalette[0]
                                : shell.surface
                            border.width: closeMouse.containsMouse ? 0 : shell.borderWidth
                            border.color: shell.border

                            Text {
                                anchors.centerIn: parent
                                text: "×"
                                color: closeMouse.containsMouse ? shell.ink : shell.text
                                font.pixelSize: Math.round(21 * shell.fontScale)
                                font.weight: Font.Black
                            }

                            MouseArea {
                                id: closeMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: shell.themePanelOpen = false
                            }
                        }
                    }

                    GridLayout {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        columns: 5
                        rowSpacing: 8
                        columnSpacing: 8

                        Repeater {
                            model: shell.themeCount

                            Rectangle {
                                id: themeCard

                                required property int index
                                property var theme: shell.themeAt(index)
                                property bool selected: shell.themeIndex === index

                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                Layout.minimumHeight: 74

                                color: selected
                                    ? theme.colours[0]
                                    : themeMouse.containsMouse
                                        ? theme.surfaceHover
                                        : theme.surface
                                radius: shell.cardRadius
                                border.width: selected ? 0 : shell.borderWidth
                                border.color: theme.border

                                Behavior on color {
                                    ColorAnimation { duration: 130 }
                                }

                                ColumnLayout {
                                    anchors {
                                        fill: parent
                                        margins: 10
                                    }
                                    spacing: 6

                                    Text {
                                        Layout.fillWidth: true
                                        text: theme.name
                                        color: themeCard.selected
                                            ? theme.ink
                                            : theme.text
                                        font.family: "JetBrainsMono Nerd Font"
                                        font.pixelSize: Math.round(10 * shell.fontScale)
                                        font.weight: Font.Black
                                        elide: Text.ElideRight
                                    }

                                    Item { Layout.fillHeight: true }

                                    Row {
                                        spacing: 4

                                        Repeater {
                                            model: 5

                                            Rectangle {
                                                required property int index
                                                width: 18
                                                height: 7
                                                radius: Math.min(shell.microRadius, 3)
                                                color: themeCard.theme.colours[index]
                                            }
                                        }
                                    }
                                }

                                MouseArea {
                                    id: themeMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: shell.applyTheme(themeCard.index)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

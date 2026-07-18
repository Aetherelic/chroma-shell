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

                width: 920
                height: 466

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
                            ? shell.barHeight + 24
                            : 0
                    bottomMargin:
                        shell.barPosition === "BOTTOM"
                            ? shell.barHeight + 21
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
                    spacing: 14

                    RowLayout {
                        Layout.fillWidth: true

                        ColumnLayout {
                            spacing: 1

                            Text {
                                text: "CHROMA//PALETTE LIBRARY"
                                color: shell.textStrong
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: Math.round(16 * shell.fontScale)
                                font.weight: Font.Black
                                font.letterSpacing: 1
                            }

                            Text {
                                text: shell.themeCount
                                    + " CURATED SYSTEM THEMES // "
                                    + shell.themeName
                                color: shell.uiPalette[0]
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: Math.round(8 * shell.fontScale)
                                font.weight: Font.Black
                                font.letterSpacing: 1.4
                            }
                        }

                        Item { Layout.fillWidth: true }

                        ColumnLayout {
                            spacing: 2

                            Text {
                                Layout.alignment: Qt.AlignRight
                                text: "CLICK TO APPLY"
                                color: shell.muted
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: Math.round(7 * shell.fontScale)
                                font.weight: Font.Bold
                                font.letterSpacing: 1.2
                            }

                            Text {
                                Layout.alignment: Qt.AlignRight
                                text: "RIGHT-CLICK THE BAR TILE TO CYCLE"
                                color: shell.dim
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: Math.round(7 * shell.fontScale)
                                font.weight: Font.Bold
                                font.letterSpacing: 1
                            }
                        }
                    }

                    GridLayout {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        columns: 4
                        rowSpacing: 8
                        columnSpacing: 8

                        Repeater {
                            model: shell.themeCount

                            Rectangle {
                                id: themeCard

                                required property int index

                                property var theme: shell.themeAt(index)
                                property bool selected:
                                    shell.themeIndex === index

                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                Layout.minimumHeight: 82

                                color: selected
                                    ? theme.colours[0]
                                    : themeMouse.containsMouse
                                        ? theme.surfaceHover
                                        : theme.surface
                                radius: shell.controlRadius
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
                                    spacing: 4

                                    RowLayout {
                                        Layout.fillWidth: true

                                        Text {
                                            text: (index + 1)
                                                .toString()
                                                .padStart(2, "0")
                                            color: themeCard.selected
                                                ? theme.ink
                                                : theme.colours[0]
                                            font.family:
                                                "JetBrainsMono Nerd Font"
                                            font.pixelSize: Math.round(8 * shell.fontScale)
                                            font.weight: Font.Black
                                        }

                                        Item { Layout.fillWidth: true }

                                        Text {
                                            text: theme.family
                                            color: themeCard.selected
                                                ? theme.ink
                                                : theme.muted
                                            opacity: 0.76
                                            font.family:
                                                "JetBrainsMono Nerd Font"
                                            font.pixelSize: Math.round(6 * shell.fontScale)
                                            font.weight: Font.Bold
                                            font.letterSpacing: 0.8
                                        }
                                    }

                                    Text {
                                        Layout.fillWidth: true
                                        text: theme.name
                                        color: themeCard.selected
                                            ? theme.ink
                                            : theme.text
                                        font.family:
                                            "JetBrainsMono Nerd Font"
                                        font.pixelSize: Math.round(10 * shell.fontScale)
                                        font.weight: Font.Black
                                        elide: Text.ElideRight
                                    }

                                    Text {
                                        Layout.fillWidth: true
                                        text: theme.description
                                        color: themeCard.selected
                                            ? theme.ink
                                            : theme.muted
                                        opacity: themeCard.selected ? 0.7 : 1
                                        font.family:
                                            "JetBrainsMono Nerd Font"
                                        font.pixelSize: Math.round(6 * shell.fontScale)
                                        font.weight: Font.Bold
                                        font.letterSpacing: 0.6
                                        elide: Text.ElideRight
                                    }

                                    Item { Layout.fillHeight: true }

                                    Row {
                                        spacing: 4

                                        Repeater {
                                            model: themeCard.theme.spectrum.length

                                            Rectangle {
                                                required property int index
                                                width: 16
                                                height: 6
                                                radius: shell.controlRadius
                                                color: themeCard
                                                    .theme
                                                    .spectrum[index]
                                                border.width:
                                                    themeCard.selected ? 1 : 0
                                                border.color:
                                                    themeCard.theme.ink
                                            }
                                        }
                                    }
                                }

                                MouseArea {
                                    id: themeMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor

                                    onClicked: {
                                        shell.applyTheme(themeCard.index)
                                        shell.themePanelOpen = false
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

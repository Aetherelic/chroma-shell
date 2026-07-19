import QtQuick
import QtQuick.Layouts
import Quickshell
import "settings/components"
import "settings/pages"

Scope {
    id: component

    required property var shell
    required property var settings

    property int pageIndex: 0
    property var pages: [
        { index: "01", name: "Wi-Fi" },
        { index: "02", name: "Bluetooth" },
        { index: "03", name: "Display" },
        { index: "04", name: "Widgets" },
        { index: "05", name: "Applications" },
        { index: "06", name: "Config" },
        { index: "07", name: "Shell Settings" },
        { index: "08", name: "About System" },
        { index: "09", name: "Credits" }
    ]

    readonly property list<Component> pageComponents: [
        wifiPageComponent,
        bluetoothPageComponent,
        displayPageComponent,
        widgetsPageComponent,
        applicationsPageComponent,
        configPageComponent,
        shellPageComponent,
        aboutPageComponent,
        creditsPageComponent
    ]

    Component {
        id: wifiPageComponent
        WifiPage { shell: component.shell; settings: component.settings }
    }

    Component {
        id: bluetoothPageComponent
        BluetoothPage { shell: component.shell; settings: component.settings }
    }

    Component {
        id: displayPageComponent
        DisplayPage { shell: component.shell; settings: component.settings }
    }

    Component {
        id: widgetsPageComponent
        WidgetsPage { shell: component.shell; settings: component.settings }
    }

    Component {
        id: applicationsPageComponent
        ApplicationsPage { shell: component.shell; settings: component.settings }
    }

    Component {
        id: configPageComponent
        ConfigPage { shell: component.shell; settings: component.settings }
    }

    Component {
        id: shellPageComponent
        ShellPage { shell: component.shell; settings: component.settings }
    }

    Component {
        id: aboutPageComponent
        AboutPage { shell: component.shell; settings: component.settings }
    }

    Component {
        id: creditsPageComponent
        CreditsPage { shell: component.shell; settings: component.settings }
    }

    FloatingWindow {
        id: settingsWindow

        visible: shell.settingsOpen
        title: "CHROMA Settings"
        implicitWidth: 1180
        implicitHeight: 760
        minimumSize: Qt.size(940, 620)
        color: shell.background

        onClosed: shell.settingsOpen = false

        Rectangle {
            id: frame
            anchors.fill: parent
            color: shell.background
            border.width: shell.borderWidth
            border.color: shell.border
            radius: shell.windowRadius
            clip: true
            focus: true

            Keys.onEscapePressed: shell.settingsOpen = false

            Row {
                anchors {
                    top: parent.top
                    left: parent.left
                    right: parent.right
                }
                height: 5

                Repeater {
                    model: shell.spectrumPalette
                    Rectangle {
                        required property var modelData
                        width: frame.width / shell.spectrumPalette.length
                        height: 5
                        color: modelData
                    }
                }
            }

            ColumnLayout {
                anchors {
                    fill: parent
                    topMargin: 5
                }
                spacing: 0

                Rectangle {
                    id: titleBar
                    Layout.fillWidth: true
                    Layout.preferredHeight: 66
                    color: shell.surface
                    border.width: shell.borderWidth
                    border.color: shell.border

                    MouseArea {
                        anchors.fill: parent
                        acceptedButtons: Qt.LeftButton
                        onPressed: settingsWindow.startSystemMove()
                    }

                    RowLayout {
                        anchors {
                            fill: parent
                            leftMargin: 18
                            rightMargin: 12
                        }
                        spacing: 12

                        Rectangle {
                            Layout.preferredWidth: 38
                            Layout.preferredHeight: 38
                            color: shell.surfaceAlt
                            radius: shell.controlRadius
                            border.width: shell.borderWidth
                            border.color: shell.border

                            Image {
                                anchors.centerIn: parent
                                width: 28
                                height: 28
                                source: Quickshell.shellPath(
                                    "assets/branding/chroma-logo.svg"
                                )
                                sourceSize: Qt.size(56, 56)
                                fillMode: Image.PreserveAspectFit
                                smooth: true
                            }
                        }

                        Text {
                            Layout.fillWidth: true
                            text: "CHROMA // SETTINGS"
                            color: shell.textStrong
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: Math.round(18 * shell.fontScale)
                            font.weight: Font.Black
                            font.letterSpacing: 0.7
                        }

                        Text {
                            text: component.pages[component.pageIndex].index
                                + " // " + component.pages[component.pageIndex].name.toUpperCase()
                            color: shell.muted
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: Math.round(8 * shell.fontScale)
                            font.weight: Font.Bold
                            font.letterSpacing: 0.8
                        }

                        SettingsButton {
                            shell: component.shell
                            label: "—"
                            implicitWidth: 38
                            onClicked: settingsWindow.minimized = true
                        }

                        SettingsButton {
                            shell: component.shell
                            label: settingsWindow.maximized ? "▣" : "□"
                            implicitWidth: 38
                            onClicked: settingsWindow.maximized = !settingsWindow.maximized
                        }

                        SettingsButton {
                            shell: component.shell
                            label: "×"
                            danger: true
                            implicitWidth: 38
                            onClicked: shell.settingsOpen = false
                        }
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    spacing: 0

                    Rectangle {
                        Layout.preferredWidth: 252
                        Layout.fillHeight: true
                        color: shell.backgroundAlt
                        border.width: shell.borderWidth
                        border.color: shell.border

                        ColumnLayout {
                            anchors {
                                fill: parent
                                margins: 14
                            }
                            spacing: 8

                            Text {
                                Layout.fillWidth: true
                                text: "SETTINGS"
                                color: shell.dim
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: Math.round(9 * shell.fontScale)
                                font.weight: Font.Black
                                font.letterSpacing: 1.2
                            }

                            Repeater {
                                model: component.pages

                                Rectangle {
                                    id: navItem
                                    required property int index
                                    required property var modelData

                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 48
                                    color: component.pageIndex === index
                                        ? shell.uiPalette[index % shell.palette.length]
                                        : navMouse.containsMouse
                                            ? shell.surfaceHover
                                            : shell.surface
                                    border.width: component.pageIndex === index ? 0 : 1
                                    border.color: shell.border
                                    radius: shell.controlRadius

                                    Behavior on color {
                                        ColorAnimation { duration: 130 }
                                    }

                                    RowLayout {
                                        anchors {
                                            fill: parent
                                            leftMargin: 12
                                            rightMargin: 10
                                        }
                                        spacing: 10

                                        Text {
                                            text: navItem.modelData.index
                                            color: component.pageIndex === navItem.index
                                                ? shell.ink
                                                : shell.uiPalette[navItem.index % shell.palette.length]
                                            font.family: "JetBrainsMono Nerd Font"
                                            font.pixelSize: Math.round(8 * shell.fontScale)
                                            font.weight: Font.Black
                                        }

                                        ColumnLayout {
                                            Layout.fillWidth: true
                                            spacing: 1

                                            Text {
                                                Layout.fillWidth: true
                                                text: navItem.modelData.name.toUpperCase()
                                                color: component.pageIndex === navItem.index
                                                    ? shell.ink
                                                    : shell.text
                                                font.family: "JetBrainsMono Nerd Font"
                                                font.pixelSize: Math.round(11 * shell.fontScale)
                                                font.weight: Font.Black
                                                elide: Text.ElideRight
                                            }

                                        }

                                        Text {
                                            text: component.pageIndex === navItem.index ? "●" : "○"
                                            color: component.pageIndex === navItem.index
                                                ? shell.ink
                                                : shell.dim
                                            font.pixelSize: Math.round(9 * shell.fontScale)
                                        }
                                    }

                                    MouseArea {
                                        id: navMouse
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: component.pageIndex = navItem.index
                                    }
                                }
                            }

                            Item { Layout.fillHeight: true }

                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 64
                                color: shell.surface
                                border.width: shell.borderWidth
                                border.color: shell.border
                                radius: shell.controlRadius

                                Image {
                                    anchors.centerIn: parent
                                    width: 42
                                    height: 42
                                    source: Quickshell.shellPath(
                                        "assets/branding/chroma-logo.svg"
                                    )
                                    sourceSize: Qt.size(84, 84)
                                    fillMode: Image.PreserveAspectFit
                                    smooth: true
                                }
                            }
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        color: shell.background

                        Loader {
                            id: pageLoader

                            anchors {
                                fill: parent
                                margins: 22
                            }

                            asynchronous: true
                            sourceComponent: pageComponents[component.pageIndex]
                        }
                    }
                }

                Item {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 0
                }
            }
        }
    }
}
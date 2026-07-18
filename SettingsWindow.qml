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
        { index: "01", name: "Wi-Fi", detail: "NETWORK" },
        { index: "02", name: "Bluetooth", detail: "DEVICES" },
        { index: "03", name: "Display", detail: "OUTPUTS" },
        { index: "04", name: "Widgets", detail: "COMPOSITION" },
        { index: "05", name: "Applications", detail: "DEFAULTS" },
        { index: "06", name: "Config", detail: "MAINTENANCE" },
        { index: "07", name: "Shell Settings", detail: "CHROMA" },
        { index: "08", name: "About System", detail: "DIAGNOSTICS" },
        { index: "09", name: "Credits", detail: "PROJECT" }
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
                            Layout.preferredWidth: 34
                            Layout.preferredHeight: 34
                            color: shell.uiPalette[0]
                            radius: shell.controlRadius

                            Text {
                                anchors.centerIn: parent
                                text: "C"
                                color: shell.ink
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: Math.round(17 * shell.fontScale)
                                font.weight: Font.Black
                            }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 1

                            Text {
                                text: "CHROMA//SETTINGS"
                                color: shell.textStrong
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: Math.round(16 * shell.fontScale)
                                font.weight: Font.Black
                                font.letterSpacing: 1
                            }

                            Text {
                                text: "SYSTEM CONFIGURATION // " + shell.themeName
                                color: shell.uiPalette[0]
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: Math.round(7 * shell.fontScale)
                                font.weight: Font.Black
                                font.letterSpacing: 1.2
                            }
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
                        Layout.preferredWidth: 236
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
                                text: "CONFIGURATION CHANNELS"
                                color: shell.dim
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: Math.round(7 * shell.fontScale)
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
                                    Layout.preferredHeight: 52
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
                                                font.pixelSize: Math.round(9 * shell.fontScale)
                                                font.weight: Font.Black
                                                elide: Text.ElideRight
                                            }

                                            Text {
                                                Layout.fillWidth: true
                                                text: navItem.modelData.detail
                                                color: component.pageIndex === navItem.index
                                                    ? shell.ink
                                                    : shell.muted
                                                opacity: 0.7
                                                font.family: "JetBrainsMono Nerd Font"
                                                font.pixelSize: Math.round(6 * shell.fontScale)
                                                font.weight: Font.Bold
                                                font.letterSpacing: 0.7
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

                                Column {
                                    anchors.centerIn: parent
                                    spacing: 3

                                    Text {
                                        text: "CHROMA LINK ONLINE"
                                        color: shell.success
                                        font.family: "JetBrainsMono Nerd Font"
                                        font.pixelSize: Math.round(7 * shell.fontScale)
                                        font.weight: Font.Black
                                        font.letterSpacing: 1
                                    }

                                    Text {
                                        text: "SUPER + ,  //  ESC TO CLOSE"
                                        color: shell.dim
                                        font.family: "JetBrainsMono Nerd Font"
                                        font.pixelSize: Math.round(6 * shell.fontScale)
                                        font.weight: Font.Bold
                                    }
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

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 30
                    color: shell.surface
                    border.width: shell.borderWidth
                    border.color: shell.border

                    RowLayout {
                        anchors {
                            fill: parent
                            leftMargin: 14
                            rightMargin: 14
                        }

                        Rectangle {
                            width: 7
                            height: 7
                            color: shell.success
                            radius: shell.controlRadius
                        }

                        Text {
                            text: settings.ready ? "SETTINGS STORE READY" : "LOADING SETTINGS STORE"
                            color: shell.muted
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: Math.round(7 * shell.fontScale)
                            font.weight: Font.Bold
                            font.letterSpacing: 0.8
                        }

                        Item { Layout.fillWidth: true }

                        Text {
                            text: "CHROMA/04 STYLE + DISPLAY"
                            color: shell.dim
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: Math.round(7 * shell.fontScale)
                            font.weight: Font.Bold
                            font.letterSpacing: 0.8
                        }
                    }
                }
            }
        }
    }
}

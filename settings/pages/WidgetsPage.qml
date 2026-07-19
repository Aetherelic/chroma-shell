import QtQuick
import QtQuick.Layouts
import Quickshell
import "../components"

Flickable {
    id: page

    required property var shell
    required property var settings

    readonly property var manager: shell.widgetManager
    property string selectedMonitor: manager.activeMonitor
    readonly property var selectedWidget: manager.findWidget(manager.selectedId)
    readonly property var fontOptions: [
        "JetBrainsMono Nerd Font",
        "Inter",
        "Noto Sans"
    ]

    readonly property var monitorOptions: {
        var result = []
        var screens = Quickshell.screens
        for (var index = 0; index < screens.length; index++) {
            result.push(screens[index].name)
        }
        return result.length > 0 ? result : [shell.resolvedBarMonitor]
    }

    readonly property var placedWidgets:
        manager.widgetsForMonitor(selectedMonitor)

    contentWidth: width
    contentHeight: content.implicitHeight + 28
    clip: true

    function updateSelectedGeometry(changes) {
        if (selectedWidget === null) {
            return
        }
        manager.updateWidget(selectedWidget.id, changes)
    }

    ColumnLayout {
        id: content
        width: page.width
        spacing: 16

        PageHeader {
            shell: page.shell
            index: "04"
            title: "Widgets"
        }

        SettingsCard {
            shell: page.shell
            Layout.fillWidth: true
            title: "Desktop canvas"
            accent: shell.uiPalette[4]

            SettingsToggle {
                shell: page.shell
                Layout.fillWidth: true
                label: "Desktop widgets"
                checked: manager.enabled
                onToggled: value => {
                    manager.enabled = value
                    manager.scheduleSave()
                }
            }

            SettingsChoice {
                shell: page.shell
                Layout.fillWidth: true
                label: "Monitor"
                options: page.monitorOptions
                current: page.selectedMonitor
                accent: shell.uiPalette[0]
                onOptionSelected: value => {
                    page.selectedMonitor = value
                    manager.activeMonitor = value
                    manager.scheduleSave()
                }
            }

            SettingsToggle {
                shell: page.shell
                Layout.fillWidth: true
                label: "Widgets on " + page.selectedMonitor
                checked: manager.isMonitorEnabled(page.selectedMonitor)
                onToggled: value => manager.setMonitorEnabled(page.selectedMonitor, value)
            }

            SettingsStepper {
                shell: page.shell
                Layout.fillWidth: true
                label: "Snap grid"
                value: manager.snapSize
                minimum: 4
                maximum: 64
                step: 4
                suffix: "px"
                accent: shell.uiPalette[5]
                onValueSelected: next => {
                    manager.snapSize = Math.round(next)
                    manager.scheduleSave()
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                SettingsButton {
                    shell: page.shell
                    Layout.fillWidth: true
                    label: manager.editMode ? "Close edit mode" : "Open edit mode"
                    accent: shell.uiPalette[4]
                    filled: true
                    onClicked: manager.editMode = !manager.editMode
                }

                SettingsButton {
                    shell: page.shell
                    Layout.fillWidth: true
                    label: "Reset monitor"
                    danger: true
                    onClicked: manager.resetMonitor(page.selectedMonitor)
                }
            }
        }

        SettingsCard {
            shell: page.shell
            Layout.fillWidth: true
            title: "Widget gallery"
            accent: shell.uiPalette[3]

            GridLayout {
                Layout.fillWidth: true
                columns: 4
                rowSpacing: 10
                columnSpacing: 10

                Repeater {
                    model: [
                        { type: "music", label: "Music", icon: "♫", accent: shell.uiPalette[0] },
                        { type: "cava", label: "CAVA", icon: "▥", accent: shell.uiPalette[4] },
                        { type: "clock", label: "Clock", icon: "◷", accent: shell.uiPalette[3] },
                        { type: "system", label: "System", icon: "▦", accent: shell.uiPalette[6] }
                    ]

                    Rectangle {
                        id: galleryCard
                        required property var modelData
                        Layout.fillWidth: true
                        Layout.preferredHeight: 86
                        color: galleryMouse.containsMouse
                            ? shell.surfaceHover
                            : shell.backgroundAlt
                        border.width: shell.borderWidth
                        border.color: galleryMouse.containsMouse
                            ? modelData.accent
                            : shell.border
                        radius: shell.cardRadius

                        ColumnLayout {
                            anchors.centerIn: parent
                            spacing: 5

                            Text {
                                Layout.alignment: Qt.AlignHCenter
                                text: galleryCard.modelData.icon
                                color: galleryCard.modelData.accent
                                font.pixelSize: 24
                                font.weight: Font.Black
                            }

                            Text {
                                Layout.alignment: Qt.AlignHCenter
                                text: galleryCard.modelData.label.toUpperCase()
                                color: shell.textStrong
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: Math.round(8 * shell.fontScale)
                                font.weight: Font.Black
                            }
                        }

                        MouseArea {
                            id: galleryMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: manager.addWidget(
                                galleryCard.modelData.type,
                                page.selectedMonitor
                            )
                        }
                    }
                }
            }
        }

        SettingsCard {
            shell: page.shell
            Layout.fillWidth: true
            title: "Placed widgets // " + page.selectedMonitor
            accent: shell.uiPalette[5]

            Text {
                visible: page.placedWidgets.length === 0
                Layout.fillWidth: true
                text: "NO WIDGETS PLACED"
                color: shell.dim
                horizontalAlignment: Text.AlignHCenter
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: Math.round(8 * shell.fontScale)
                font.weight: Font.Bold
            }

            Repeater {
                model: page.placedWidgets

                Rectangle {
                    id: row
                    required property var modelData
                    Layout.fillWidth: true
                    Layout.preferredHeight: 64
                    color: manager.selectedId === modelData.id
                        ? shell.surfaceHover
                        : shell.backgroundAlt
                    border.width: shell.borderWidth
                    border.color: manager.selectedId === modelData.id
                        ? shell.uiPalette[4]
                        : shell.border
                    radius: shell.cardRadius

                    RowLayout {
                        anchors { fill: parent; margins: 10 }
                        spacing: 10

                        Rectangle {
                            Layout.preferredWidth: 34
                            Layout.preferredHeight: 34
                            color: shell.uiPalette[4]
                            radius: shell.controlRadius

                            Text {
                                anchors.centerIn: parent
                                text: row.modelData.type.substring(0, 1).toUpperCase()
                                color: shell.ink
                                font.weight: Font.Black
                            }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 2

                            Text {
                                text: row.modelData.type.toUpperCase()
                                color: shell.textStrong
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: Math.round(9 * shell.fontScale)
                                font.weight: Font.Black
                            }

                            Text {
                                text: row.modelData.width + " × " + row.modelData.height
                                    + "  ·  " + (row.modelData.locked ? "LOCKED" : "EDITABLE")
                                color: shell.muted
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: Math.round(7 * shell.fontScale)
                                font.weight: Font.Bold
                            }
                        }

                        SettingsButton {
                            shell: page.shell
                            label: row.modelData.locked ? "Unlock" : "Lock"
                            onClicked: manager.setLocked(
                                row.modelData.id,
                                !row.modelData.locked
                            )
                        }

                        SettingsButton {
                            shell: page.shell
                            label: "Duplicate"
                            onClicked: manager.duplicateWidget(row.modelData.id)
                        }

                        SettingsButton {
                            shell: page.shell
                            label: "Remove"
                            danger: true
                            onClicked: manager.removeWidget(row.modelData.id)
                        }
                    }

                    MouseArea {
                        anchors { fill: parent; rightMargin: 286 }
                        cursorShape: Qt.PointingHandCursor
                        onClicked: manager.selectedId = row.modelData.id
                    }
                }
            }
        }

        SettingsCard {
            visible: page.selectedWidget !== null
            shell: page.shell
            Layout.fillWidth: true
            title: page.selectedWidget !== null
                ? "Selected // " + page.selectedWidget.type
                : "Selected widget"
            accent: shell.uiPalette[0]

            SettingsChoice {
                shell: page.shell
                Layout.fillWidth: true
                label: "Font"
                options: page.fontOptions
                current: page.selectedWidget !== null
                    ? String(page.selectedWidget.settings.fontFamily)
                    : "JetBrainsMono Nerd Font"
                accent: shell.uiPalette[0]
                onOptionSelected: value => manager.updateWidgetSettings(
                    page.selectedWidget.id,
                    { fontFamily: value }
                )
            }

            SettingsStepper {
                shell: page.shell
                Layout.fillWidth: true
                label: "Text scale"
                value: page.selectedWidget !== null
                    ? Number(page.selectedWidget.settings.fontScale) * 100
                    : 100
                minimum: 70
                maximum: 180
                step: 5
                suffix: "%"
                accent: shell.uiPalette[4]
                onValueSelected: next => manager.updateWidgetSettings(
                    page.selectedWidget.id,
                    { fontScale: next / 100 }
                )
            }

            SettingsChoice {
                shell: page.shell
                Layout.fillWidth: true
                label: "Surface"
                options: ["SOLID", "TRANSLUCENT", "TRANSPARENT"]
                current: page.selectedWidget !== null
                    ? String(page.selectedWidget.settings.surface)
                    : "SOLID"
                accent: shell.uiPalette[3]
                onOptionSelected: value => manager.updateWidgetSettings(
                    page.selectedWidget.id,
                    { surface: value }
                )
            }

            GridLayout {
                Layout.fillWidth: true
                columns: 2
                columnSpacing: 18
                rowSpacing: 4

                SettingsStepper {
                    shell: page.shell
                    Layout.fillWidth: true
                    label: "Width"
                    value: page.selectedWidget !== null ? page.selectedWidget.width : 380
                    minimum: 220
                    maximum: 900
                    step: manager.snapSize
                    suffix: "px"
                    accent: shell.uiPalette[5]
                    onValueSelected: next => page.updateSelectedGeometry({ width: next })
                }

                SettingsStepper {
                    shell: page.shell
                    Layout.fillWidth: true
                    label: "Height"
                    value: page.selectedWidget !== null ? page.selectedWidget.height : 180
                    minimum: 120
                    maximum: 600
                    step: manager.snapSize
                    suffix: "px"
                    accent: shell.uiPalette[5]
                    onValueSelected: next => page.updateSelectedGeometry({ height: next })
                }

                SettingsStepper {
                    shell: page.shell
                    Layout.fillWidth: true
                    label: "Horizontal position"
                    value: page.selectedWidget !== null
                        ? Math.round(page.selectedWidget.x * 100)
                        : 0
                    minimum: 0
                    maximum: 100
                    step: 5
                    suffix: "%"
                    accent: shell.uiPalette[0]
                    onValueSelected: next => page.updateSelectedGeometry({ x: next / 100 })
                }

                SettingsStepper {
                    shell: page.shell
                    Layout.fillWidth: true
                    label: "Vertical position"
                    value: page.selectedWidget !== null
                        ? Math.round(page.selectedWidget.y * 100)
                        : 0
                    minimum: 0
                    maximum: 100
                    step: 5
                    suffix: "%"
                    accent: shell.uiPalette[0]
                    onValueSelected: next => page.updateSelectedGeometry({ y: next / 100 })
                }
            }

            Text {
                Layout.fillWidth: true
                text: "POSITION PRESETS"
                color: shell.dim
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: Math.round(7 * shell.fontScale)
                font.weight: Font.Black
                font.letterSpacing: 1
            }

            GridLayout {
                Layout.fillWidth: true
                columns: 3
                rowSpacing: 8
                columnSpacing: 8

                Repeater {
                    model: [
                        "TOP LEFT", "TOP", "TOP RIGHT",
                        "LEFT", "CENTER", "RIGHT",
                        "BOTTOM LEFT", "BOTTOM", "BOTTOM RIGHT"
                    ]

                    SettingsButton {
                        required property var modelData
                        shell: page.shell
                        Layout.fillWidth: true
                        label: String(modelData)
                        onClicked: manager.placeWidget(
                            page.selectedWidget.id,
                            String(modelData)
                        )
                    }
                }
            }

            SettingsToggle {
                visible: page.selectedWidget !== null
                    && page.selectedWidget.type === "clock"
                shell: page.shell
                Layout.fillWidth: true
                label: "Show date"
                checked: page.selectedWidget !== null
                    && page.selectedWidget.settings.date !== false
                onToggled: value => manager.updateWidgetSettings(
                    page.selectedWidget.id,
                    { date: value }
                )
            }

            SettingsToggle {
                visible: page.selectedWidget !== null
                    && page.selectedWidget.type === "clock"
                shell: page.shell
                Layout.fillWidth: true
                label: "Show seconds"
                checked: page.selectedWidget !== null
                    && page.selectedWidget.settings.seconds === true
                onToggled: value => manager.updateWidgetSettings(
                    page.selectedWidget.id,
                    { seconds: value }
                )
            }

            SettingsToggle {
                visible: page.selectedWidget !== null
                    && page.selectedWidget.type === "music"
                shell: page.shell
                Layout.fillWidth: true
                label: "Album artwork"
                checked: page.selectedWidget !== null
                    && page.selectedWidget.settings.artwork !== false
                onToggled: value => manager.updateWidgetSettings(
                    page.selectedWidget.id,
                    { artwork: value }
                )
            }

            SettingsToggle {
                visible: page.selectedWidget !== null
                    && page.selectedWidget.type === "music"
                shell: page.shell
                Layout.fillWidth: true
                label: "Playback controls"
                checked: page.selectedWidget !== null
                    && page.selectedWidget.settings.controls !== false
                onToggled: value => manager.updateWidgetSettings(
                    page.selectedWidget.id,
                    { controls: value }
                )
            }
        }
    }
}

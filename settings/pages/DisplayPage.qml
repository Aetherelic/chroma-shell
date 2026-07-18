import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import "../components"

Flickable {
    id: page

    required property var shell
    required property var settings

    property var monitors: []
    property int selectedIndex: 0
    property string selectedName: ""
    property string editMode: ""
    property real editScale: 1.0
    property int editX: 0
    property int editY: 0
    property int editTransform: 0
    property bool editVrr: false
    property bool editEnabled: true
    property string pendingToken: ""
    property int pendingSeconds: 0
    property string statusMessage: ""
    property bool busy: false

    readonly property var selectedMonitor:
        selectedIndex >= 0 && selectedIndex < monitors.length
            ? monitors[selectedIndex]
            : null

    readonly property var modeOptions:
        selectedMonitor && selectedMonitor.availableModes
            ? selectedMonitor.availableModes
            : []

    contentWidth: width
    contentHeight: content.implicitHeight + 28
    clip: true

    function transformLabel(value) {
        switch (Number(value)) {
        case 1: return "90"
        case 2: return "180"
        case 3: return "270"
        default: return "NORMAL"
        }
    }

    function transformValue(label) {
        switch (String(label)) {
        case "90": return 1
        case "180": return 2
        case "270": return 3
        default: return 0
        }
    }

    function currentMode(monitor) {
        if (!monitor) {
            return ""
        }

        var prefix = monitor.width + "x" + monitor.height + "@"
        var modes = monitor.availableModes || []
        var refresh = Number(monitor.refreshRate || 0)
        var best = ""
        var bestDelta = 99999

        for (var index = 0; index < modes.length; index++) {
            var mode = String(modes[index])
            if (mode.indexOf(prefix) !== 0) {
                continue
            }
            var parsed = Number(mode.substring(prefix.length).replace("Hz", ""))
            var delta = Math.abs(parsed - refresh)
            if (delta < bestDelta) {
                best = mode
                bestDelta = delta
            }
        }

        return best.length > 0 ? best : prefix + refresh.toFixed(2) + "Hz"
    }

    function loadEditor() {
        var monitor = selectedMonitor
        if (!monitor) {
            return
        }

        selectedName = monitor.name || ""
        editMode = currentMode(monitor)
        editScale = Number(monitor.scale || 1)
        editX = Number(monitor.x || 0)
        editY = Number(monitor.y || 0)
        editTransform = Number(monitor.transform || 0)
        editVrr = monitor.vrr === true
        editEnabled = monitor.disabled !== true
    }

    function refresh() {
        busy = true
        refreshProcess.exec([
            "bash",
            Quickshell.shellPath("backend/chroma-settingsctl"),
            "display-json"
        ])
    }

    function preview() {
        if (!selectedMonitor || busy) {
            return
        }

        busy = true
        statusMessage = "APPLYING TEMPORARY DISPLAY CONFIGURATION"
        previewProcess.exec([
            "bash",
            Quickshell.shellPath("backend/chroma-settingsctl"),
            "display-preview",
            selectedName,
            editMode,
            String(Math.round(editX)),
            String(Math.round(editY)),
            Number(editScale).toFixed(2),
            String(editTransform),
            editVrr ? "1" : "0",
            editEnabled ? "1" : "0"
        ])
    }

    function keepPreview() {
        if (pendingToken.length === 0) {
            return
        }
        keepProcess.exec([
            "bash",
            Quickshell.shellPath("backend/chroma-settingsctl"),
            "display-keep",
            pendingToken
        ])
    }

    function revertPreview() {
        if (pendingToken.length === 0) {
            return
        }
        revertProcess.exec([
            "bash",
            Quickshell.shellPath("backend/chroma-settingsctl"),
            "display-revert",
            pendingToken
        ])
    }

    Process {
        id: refreshProcess
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    var data = JSON.parse(text)
                    page.monitors = data
                    var found = -1
                    for (var index = 0; index < data.length; index++) {
                        if (data[index].name === page.selectedName) {
                            found = index
                            break
                        }
                    }
                    page.selectedIndex = found >= 0 ? found : (data.length > 0 ? 0 : -1)
                    page.loadEditor()
                    page.statusMessage = data.length + " OUTPUTS INDEXED"
                } catch (error) {
                    page.statusMessage = "DISPLAY REPORT COULD NOT BE PARSED"
                }
                page.busy = false
            }
        }
        stderr: StdioCollector {
            onStreamFinished: {
                if (text.trim().length > 0) {
                    page.statusMessage = text.trim()
                }
                page.busy = false
            }
        }
    }

    Process {
        id: previewProcess
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    var result = JSON.parse(text)
                    page.statusMessage = result.message || "DISPLAY PREVIEW APPLIED"
                    if (result.ok) {
                        page.pendingToken = result.token || ""
                        page.pendingSeconds = 15
                        confirmationTimer.restart()
                    }
                } catch (error) {
                    page.statusMessage = text.trim()
                }
                page.busy = false
            }
        }
        stderr: StdioCollector {
            onStreamFinished: {
                if (text.trim().length > 0) {
                    page.statusMessage = text.trim()
                }
                page.busy = false
            }
        }
    }

    Process {
        id: keepProcess
        stdout: StdioCollector {
            onStreamFinished: {
                page.statusMessage = text.trim().length > 0
                    ? text.trim()
                    : "DISPLAY CONFIGURATION SAVED"
                page.pendingToken = ""
                page.pendingSeconds = 0
                confirmationTimer.stop()
                page.refresh()
            }
        }
    }

    Process {
        id: revertProcess
        stdout: StdioCollector {
            onStreamFinished: {
                page.statusMessage = text.trim().length > 0
                    ? text.trim()
                    : "DISPLAY CONFIGURATION RESTORED"
                page.pendingToken = ""
                page.pendingSeconds = 0
                confirmationTimer.stop()
                page.refresh()
            }
        }
    }

    Timer {
        id: confirmationTimer
        interval: 1000
        repeat: true
        onTriggered: {
            page.pendingSeconds--
            if (page.pendingSeconds <= 0) {
                stop()
                page.revertPreview()
            }
        }
    }

    Component.onCompleted: refresh()

    ColumnLayout {
        id: content
        width: page.width
        spacing: 16

        PageHeader {
            shell: page.shell
            index: "03"
            title: "Display"
        }

        SettingsCard {
            visible: page.pendingToken.length > 0
            shell: page.shell
            Layout.fillWidth: true
            title: "Keep this display configuration?"
            accent: shell.warning

            RowLayout {
                Layout.fillWidth: true
                spacing: 12

                Text {
                    Layout.fillWidth: true
                    text: "AUTOMATIC REVERT IN " + page.pendingSeconds + " SECONDS"
                    color: shell.warning
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: Math.round(11 * shell.fontScale)
                    font.weight: Font.Black
                    font.letterSpacing: 1
                }

                SettingsButton {
                    shell: page.shell
                    label: "Revert"
                    danger: true
                    onClicked: page.revertPreview()
                }

                SettingsButton {
                    shell: page.shell
                    label: "Keep"
                    accent: shell.success
                    filled: true
                    onClicked: page.keepPreview()
                }
            }
        }

        SettingsCard {
            shell: page.shell
            Layout.fillWidth: true
            title: "Connected outputs"
            accent: shell.uiPalette[4]

            GridLayout {
                Layout.fillWidth: true
                columns: 2
                rowSpacing: 10
                columnSpacing: 10

                Repeater {
                    model: page.monitors

                    Rectangle {
                        id: monitorCard
                        required property int index
                        required property var modelData

                        Layout.fillWidth: true
                        Layout.preferredHeight: 128
                        color: page.selectedIndex === index
                            ? shell.surfaceAlt
                            : monitorMouse.containsMouse
                                ? shell.surfaceHover
                                : shell.backgroundAlt
                        border.width: page.selectedIndex === index
                            ? Math.max(2, shell.borderWidth)
                            : shell.borderWidth
                        border.color: page.selectedIndex === index
                            ? shell.uiPalette[index % shell.uiPalette.length]
                            : shell.border
                        radius: shell.cardRadius

                        ColumnLayout {
                            anchors { fill: parent; margins: 14 }
                            spacing: 7

                            RowLayout {
                                Layout.fillWidth: true

                                Text {
                                    Layout.fillWidth: true
                                    text: monitorCard.modelData.name
                                    color: shell.textStrong
                                    font.family: "JetBrainsMono Nerd Font"
                                    font.pixelSize: Math.round(12 * shell.fontScale)
                                    font.weight: Font.Black
                                }

                                Text {
                                    text: monitorCard.modelData.focused ? "FOCUSED" : "OUTPUT"
                                    color: monitorCard.modelData.focused
                                        ? shell.success
                                        : shell.dim
                                    font.family: "JetBrainsMono Nerd Font"
                                    font.pixelSize: Math.round(8 * shell.fontScale)
                                    font.weight: Font.Black
                                }
                            }

                            Text {
                                Layout.fillWidth: true
                                text: (monitorCard.modelData.model || monitorCard.modelData.description || "CONNECTED MONITOR").toUpperCase()
                                color: shell.muted
                                elide: Text.ElideRight
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: Math.round(8 * shell.fontScale)
                                font.weight: Font.Bold
                            }

                            Text {
                                Layout.fillWidth: true
                                text: monitorCard.modelData.width + "×" + monitorCard.modelData.height
                                    + " @ " + Number(monitorCard.modelData.refreshRate || 0).toFixed(2) + " HZ"
                                    + "  //  " + Number(monitorCard.modelData.scale || 1).toFixed(2) + "×"
                                color: shell.uiPalette[index % shell.uiPalette.length]
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: Math.round(9 * shell.fontScale)
                                font.weight: Font.Black
                            }
                        }

                        MouseArea {
                            id: monitorMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                page.selectedIndex = monitorCard.index
                                page.loadEditor()
                            }
                        }
                    }
                }
            }
        }

        SettingsCard {
            visible: page.selectedMonitor !== null
            shell: page.shell
            Layout.fillWidth: true
            title: page.selectedMonitor
                ? "Configure // " + page.selectedMonitor.name
                : "Configure output"
            accent: shell.uiPalette[5]

            SettingsToggle {
                shell: page.shell
                Layout.fillWidth: true
                label: "Output enabled"
                checked: page.editEnabled
                accent: shell.success
                onToggled: value => page.editEnabled = value
            }

            SettingsCycle {
                shell: page.shell
                Layout.fillWidth: true
                label: "Resolution and refresh"
                options: page.modeOptions
                current: page.editMode
                accent: shell.uiPalette[4]
                onOptionSelected: value => page.editMode = value
            }

            SettingsStepper {
                shell: page.shell
                Layout.fillWidth: true
                label: "Scale"
                value: page.editScale
                minimum: 0.75
                maximum: 2.00
                step: 0.05
                decimals: 2
                suffix: "×"
                accent: shell.uiPalette[3]
                onValueSelected: next => page.editScale = next
            }

            SettingsChoice {
                shell: page.shell
                Layout.fillWidth: true
                label: "Rotation"
                options: ["NORMAL", "90", "180", "270"]
                current: page.transformLabel(page.editTransform)
                accent: shell.uiPalette[6]
                onOptionSelected: value => page.editTransform = page.transformValue(value)
            }

            SettingsToggle {
                shell: page.shell
                Layout.fillWidth: true
                label: "Adaptive sync / VRR"
                checked: page.editVrr
                accent: shell.uiPalette[4]
                onToggled: value => page.editVrr = value
            }

            SettingsStepper {
                shell: page.shell
                Layout.fillWidth: true
                label: "Horizontal position"
                value: page.editX
                minimum: -7680
                maximum: 7680
                step: 10
                suffix: "px"
                accent: shell.uiPalette[1]
                onValueSelected: next => page.editX = Math.round(next)
            }

            SettingsStepper {
                shell: page.shell
                Layout.fillWidth: true
                label: "Vertical position"
                value: page.editY
                minimum: -4320
                maximum: 4320
                step: 10
                suffix: "px"
                accent: shell.uiPalette[2]
                onValueSelected: next => page.editY = Math.round(next)
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                SettingsButton {
                    shell: page.shell
                    Layout.fillWidth: true
                    label: page.busy ? "Working" : "Preview changes"
                    accent: shell.warning
                    filled: true
                    enabled: !page.busy && page.pendingToken.length === 0
                    onClicked: page.preview()
                }

                SettingsButton {
                    shell: page.shell
                    label: "Refresh"
                    accent: shell.uiPalette[4]
                    enabled: !page.busy
                    onClicked: page.refresh()
                }
            }
        }

        SettingsCard {
            shell: page.shell
            Layout.fillWidth: true
            title: "Display tools"
            accent: shell.uiPalette[1]

            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                SettingsButton {
                    shell: page.shell
                    label: "Open config"
                    accent: shell.uiPalette[4]
                    onClicked: Quickshell.execDetached([
                        "bash",
                        Quickshell.shellPath("backend/chroma-settingsctl"),
                        "open-display-config"
                    ])
                }

                SettingsButton {
                    shell: page.shell
                    label: "Copy report"
                    accent: shell.uiPalette[6]
                    onClicked: Quickshell.execDetached([
                        "bash",
                        Quickshell.shellPath("backend/chroma-settingsctl"),
                        "copy-monitors"
                    ])
                }

                Text {
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignRight
                    text: page.statusMessage
                    color: shell.muted
                    elide: Text.ElideRight
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: Math.round(8 * shell.fontScale)
                    font.weight: Font.Bold
                }
            }
        }
    }
}

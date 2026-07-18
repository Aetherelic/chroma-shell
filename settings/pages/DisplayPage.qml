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
    property string editResolution: ""
    property string editRefresh: ""
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

    readonly property int canvasPadding: 28
    readonly property int canvasSnap: 10

    readonly property var selectedMonitor:
        selectedIndex >= 0 && selectedIndex < monitors.length
            ? monitors[selectedIndex]
            : null

    readonly property var modeOptions:
        selectedMonitor && selectedMonitor.availableModes
            ? selectedMonitor.availableModes
            : []

    readonly property var resolutionOptions: {
        var result = []
        var modes = page.modeOptions

        for (var index = 0; index < modes.length; index++) {
            var resolution = String(modes[index]).split("@")[0]
            if (result.indexOf(resolution) < 0) {
                result.push(resolution)
            }
        }

        return result
    }

    readonly property var refreshOptions: {
        var result = []
        var modes = page.modeOptions
        var prefix = page.editResolution + "@"

        for (var index = 0; index < modes.length; index++) {
            var mode = String(modes[index])
            if (mode.indexOf(prefix) !== 0) {
                continue
            }

            var refresh = mode.substring(prefix.length).replace("Hz", "")
            if (result.indexOf(refresh) < 0) {
                result.push(refresh)
            }
        }

        return result
    }

    readonly property string editMode:
        editResolution.length > 0 && editRefresh.length > 0
            ? editResolution + "@" + editRefresh + "Hz"
            : ""

    readonly property var layoutBounds: {
        var active = []

        for (var index = 0; index < page.monitors.length; index++) {
            var monitor = page.monitors[index]
            if (page.monitorEnabled(monitor)) {
                active.push(monitor)
            }
        }

        if (active.length === 0) {
            return {
                minX: 0,
                minY: 0,
                maxX: 1920,
                maxY: 1080,
                width: 1920,
                height: 1080
            }
        }

        var minX = 999999
        var minY = 999999
        var maxX = -999999
        var maxY = -999999

        for (var item = 0; item < active.length; item++) {
            var output = active[item]
            var x = page.monitorX(output)
            var y = page.monitorY(output)
            var width = page.monitorLogicalWidth(output)
            var height = page.monitorLogicalHeight(output)

            minX = Math.min(minX, x)
            minY = Math.min(minY, y)
            maxX = Math.max(maxX, x + width)
            maxY = Math.max(maxY, y + height)
        }

        return {
            minX: minX,
            minY: minY,
            maxX: maxX,
            maxY: maxY,
            width: Math.max(1, maxX - minX),
            height: Math.max(1, maxY - minY)
        }
    }

    readonly property real layoutScale: {
        var availableWidth = Math.max(1, layoutCanvas.width - canvasPadding * 2)
        var availableHeight = Math.max(1, layoutCanvas.height - canvasPadding * 2)
        return Math.min(
            availableWidth / Math.max(1, layoutBounds.width),
            availableHeight / Math.max(1, layoutBounds.height)
        )
    }

    contentWidth: width
    contentHeight: content.implicitHeight + 28
    clip: true

    function clamp(value, minimum, maximum) {
        return Math.max(minimum, Math.min(maximum, value))
    }

    function snap(value) {
        return Math.round(value / canvasSnap) * canvasSnap
    }

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

    function modeParts(mode) {
        var text = String(mode || "")
        var pieces = text.split("@")

        return {
            resolution: pieces.length > 0 ? pieces[0] : "",
            refresh: pieces.length > 1
                ? pieces[1].replace("Hz", "")
                : ""
        }
    }

    function resolutionSize(resolution) {
        var pieces = String(resolution || "").split("x")
        return {
            width: pieces.length > 0 ? Number(pieces[0]) : 1920,
            height: pieces.length > 1 ? Number(pieces[1]) : 1080
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

            var parsed = Number(
                mode.substring(prefix.length).replace("Hz", "")
            )
            var delta = Math.abs(parsed - refresh)

            if (delta < bestDelta) {
                best = mode
                bestDelta = delta
            }
        }

        return best.length > 0
            ? best
            : prefix + refresh.toFixed(2) + "Hz"
    }

    function monitorIsSelected(monitor) {
        return monitor && monitor.name === selectedName
    }

    function monitorEnabled(monitor) {
        return monitorIsSelected(monitor)
            ? editEnabled
            : monitor && monitor.disabled !== true
    }

    function monitorTransform(monitor) {
        return monitorIsSelected(monitor)
            ? editTransform
            : Number(monitor.transform || 0)
    }

    function monitorScale(monitor) {
        return Math.max(
            0.25,
            monitorIsSelected(monitor)
                ? Number(editScale || 1)
                : Number(monitor.scale || 1)
        )
    }

    function monitorPixelSize(monitor) {
        if (monitorIsSelected(monitor) && editResolution.length > 0) {
            return resolutionSize(editResolution)
        }

        return {
            width: Math.max(1, Number(monitor.width || 1920)),
            height: Math.max(1, Number(monitor.height || 1080))
        }
    }

    function monitorLogicalWidth(monitor) {
        var size = monitorPixelSize(monitor)
        var transform = monitorTransform(monitor)
        var width = transform === 1 || transform === 3
            ? size.height
            : size.width
        return width / monitorScale(monitor)
    }

    function monitorLogicalHeight(monitor) {
        var size = monitorPixelSize(monitor)
        var transform = monitorTransform(monitor)
        var height = transform === 1 || transform === 3
            ? size.width
            : size.height
        return height / monitorScale(monitor)
    }

    function monitorX(monitor) {
        return monitorIsSelected(monitor)
            ? Number(editX || 0)
            : Number(monitor.x || 0)
    }

    function monitorY(monitor) {
        return monitorIsSelected(monitor)
            ? Number(editY || 0)
            : Number(monitor.y || 0)
    }

    function canvasX(monitor) {
        return canvasPadding
            + (monitorX(monitor) - layoutBounds.minX) * layoutScale
    }

    function canvasY(monitor) {
        return canvasPadding
            + (monitorY(monitor) - layoutBounds.minY) * layoutScale
    }

    function canvasWidth(monitor) {
        return Math.max(72, monitorLogicalWidth(monitor) * layoutScale)
    }

    function canvasHeight(monitor) {
        return Math.max(48, monitorLogicalHeight(monitor) * layoutScale)
    }

    function otherActiveMonitor() {
        for (var index = 0; index < monitors.length; index++) {
            var monitor = monitors[index]
            if (!monitorIsSelected(monitor) && monitor.disabled !== true) {
                return monitor
            }
        }
        return null
    }

    function placeRelative(direction) {
        var reference = otherActiveMonitor()
        var monitor = selectedMonitor

        if (!reference || !monitor || !editEnabled) {
            statusMessage = "A SECOND ACTIVE OUTPUT IS REQUIRED"
            return
        }

        var selectedWidth = monitorLogicalWidth(monitor)
        var selectedHeight = monitorLogicalHeight(monitor)
        var referenceX = monitorX(reference)
        var referenceY = monitorY(reference)
        var referenceWidth = monitorLogicalWidth(reference)
        var referenceHeight = monitorLogicalHeight(reference)

        switch (direction) {
        case "LEFT":
            editX = Math.round(referenceX - selectedWidth)
            editY = Math.round(referenceY)
            break
        case "RIGHT":
            editX = Math.round(referenceX + referenceWidth)
            editY = Math.round(referenceY)
            break
        case "ABOVE":
            editX = Math.round(referenceX)
            editY = Math.round(referenceY - selectedHeight)
            break
        case "BELOW":
            editX = Math.round(referenceX)
            editY = Math.round(referenceY + referenceHeight)
            break
        }

        statusMessage = selectedName + " PLACED " + direction
    }

    function loadEditor() {
        var monitor = selectedMonitor
        if (!monitor) {
            return
        }

        selectedName = monitor.name || ""

        var parts = modeParts(currentMode(monitor))
        editResolution = parts.resolution
        editRefresh = parts.refresh
        editScale = Number(monitor.scale || 1)
        editX = Number(monitor.x || 0)
        editY = Number(monitor.y || 0)
        editTransform = Number(monitor.transform || 0)
        editVrr = monitor.vrr === true
        editEnabled = monitor.disabled !== true
    }

    function refresh() {
        if (busy) {
            return
        }

        busy = true
        refreshProcess.exec([
            "bash",
            Quickshell.shellPath("backend/chroma-settingsctl"),
            "display-json"
        ])
    }

    function preview() {
        if (!selectedMonitor || busy || editMode.length === 0) {
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
        if (pendingToken.length === 0 || busy) {
            return
        }

        busy = true
        keepProcess.exec([
            "bash",
            Quickshell.shellPath("backend/chroma-settingsctl"),
            "display-keep",
            pendingToken
        ])
    }

    function revertPreview() {
        if (pendingToken.length === 0 || busy) {
            return
        }

        busy = true
        revertProcess.exec([
            "bash",
            Quickshell.shellPath("backend/chroma-settingsctl"),
            "display-revert",
            pendingToken
        ])
    }

    function selectMonitor(index) {
        if (index < 0 || index >= monitors.length) {
            return
        }

        selectedIndex = index
        loadEditor()
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

                    page.selectedIndex = found >= 0
                        ? found
                        : (data.length > 0 ? 0 : -1)
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
                    page.statusMessage = result.message
                        || "DISPLAY PREVIEW APPLIED"

                    if (result.ok) {
                        page.pendingToken = result.token || ""
                        page.pendingSeconds = Number(result.seconds || 15)
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
                page.busy = false
                confirmationTimer.stop()
                page.refresh()
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
        id: revertProcess

        stdout: StdioCollector {
            onStreamFinished: {
                page.statusMessage = text.trim().length > 0
                    ? text.trim()
                    : "DISPLAY CONFIGURATION RESTORED"
                page.pendingToken = ""
                page.pendingSeconds = 0
                page.busy = false
                confirmationTimer.stop()
                page.refresh()
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
        id: actionProcess

        stdout: StdioCollector {
            onStreamFinished: {
                page.statusMessage = text.trim()
                page.busy = false
                page.refresh()
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
                    text: "AUTOMATIC REVERT IN "
                        + page.pendingSeconds
                        + " SECONDS"
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
                    enabled: !page.busy
                    onClicked: page.revertPreview()
                }

                SettingsButton {
                    shell: page.shell
                    label: "Keep"
                    accent: shell.success
                    filled: true
                    enabled: !page.busy
                    onClicked: page.keepPreview()
                }
            }
        }

        SettingsCard {
            shell: page.shell
            Layout.fillWidth: true
            title: "Display layout"
            accent: shell.uiPalette[2]

            Rectangle {
                id: layoutCanvas
                Layout.fillWidth: true
                Layout.preferredHeight: 260
                color: shell.backgroundAlt
                border.width: shell.borderWidth
                border.color: shell.border
                radius: shell.cardRadius
                clip: true

                Repeater {
                    model: page.monitors

                    Rectangle {
                        id: monitorVisual

                        required property int index
                        required property var modelData

                        property bool selected:
                            page.selectedIndex === monitorVisual.index

                        x: page.canvasX(modelData)
                        y: page.canvasY(modelData)
                        width: page.canvasWidth(modelData)
                        height: page.canvasHeight(modelData)
                        visible: page.monitorEnabled(modelData)

                        color: selected
                            ? shell.uiPalette[index % shell.uiPalette.length]
                            : layoutMouse.containsMouse
                                ? shell.surfaceHover
                                : shell.surface
                        border.width: selected
                            ? 0
                            : Math.max(1, shell.borderWidth)
                        border.color: shell.borderStrong
                        radius: shell.cardRadius

                        Behavior on color {
                            ColorAnimation { duration: 120 }
                        }

                        Column {
                            anchors.centerIn: parent
                            width: Math.max(1, parent.width - 20)
                            spacing: 4

                            Text {
                                width: parent.width
                                text: monitorVisual.modelData.name
                                color: monitorVisual.selected
                                    ? shell.ink
                                    : shell.textStrong
                                horizontalAlignment: Text.AlignHCenter
                                elide: Text.ElideRight
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: Math.round(
                                    11 * shell.fontScale
                                )
                                font.weight: Font.Black
                            }

                            Text {
                                width: parent.width
                                text: Math.round(
                                    page.monitorLogicalWidth(
                                        monitorVisual.modelData
                                    )
                                )
                                    + "×"
                                    + Math.round(
                                        page.monitorLogicalHeight(
                                            monitorVisual.modelData
                                        )
                                    )
                                color: monitorVisual.selected
                                    ? shell.ink
                                    : shell.muted
                                horizontalAlignment: Text.AlignHCenter
                                elide: Text.ElideRight
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: Math.round(
                                    8 * shell.fontScale
                                )
                                font.weight: Font.Bold
                            }
                        }

                        MouseArea {
                            id: layoutMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: monitorVisual.selected
                                ? Qt.SizeAllCursor
                                : Qt.PointingHandCursor
                            enabled: page.pendingToken.length === 0
                                && !page.busy
                            drag.target: monitorVisual.selected
                                && page.editEnabled
                                    ? monitorVisual
                                    : null
                            drag.axis: Drag.XAndYAxis

                            onPressed: {
                                if (!monitorVisual.selected) {
                                    page.selectMonitor(monitorVisual.index)
                                }
                            }

                            onReleased: {
                                if (!monitorVisual.selected
                                        || !page.editEnabled) {
                                    return
                                }

                                var logicalX = page.layoutBounds.minX
                                    + (monitorVisual.x
                                        - page.canvasPadding)
                                        / page.layoutScale
                                var logicalY = page.layoutBounds.minY
                                    + (monitorVisual.y
                                        - page.canvasPadding)
                                        / page.layoutScale

                                page.editX = page.snap(logicalX)
                                page.editY = page.snap(logicalY)
                                page.statusMessage = page.selectedName
                                    + " POSITION UPDATED"

                                monitorVisual.x = Qt.binding(function() {
                                    return page.canvasX(
                                        monitorVisual.modelData
                                    )
                                })
                                monitorVisual.y = Qt.binding(function() {
                                    return page.canvasY(
                                        monitorVisual.modelData
                                    )
                                })
                            }
                        }
                    }
                }

                Text {
                    visible: page.monitors.length === 0
                    anchors.centerIn: parent
                    text: "NO DISPLAY OUTPUTS REPORTED"
                    color: shell.muted
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: Math.round(10 * shell.fontScale)
                    font.weight: Font.Black
                }

                Text {
                    anchors {
                        right: parent.right
                        bottom: parent.bottom
                        margins: 12
                    }
                    text: "DRAG SELECTED OUTPUT // "
                        + page.canvasSnap
                        + "PX SNAP"
                    color: shell.dim
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: Math.round(7 * shell.fontScale)
                    font.weight: Font.Bold
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                SettingsButton {
                    shell: page.shell
                    Layout.fillWidth: true
                    label: "Left"
                    enabled: page.monitors.length > 1
                        && page.pendingToken.length === 0
                    onClicked: page.placeRelative("LEFT")
                }

                SettingsButton {
                    shell: page.shell
                    Layout.fillWidth: true
                    label: "Right"
                    enabled: page.monitors.length > 1
                        && page.pendingToken.length === 0
                    onClicked: page.placeRelative("RIGHT")
                }

                SettingsButton {
                    shell: page.shell
                    Layout.fillWidth: true
                    label: "Above"
                    enabled: page.monitors.length > 1
                        && page.pendingToken.length === 0
                    onClicked: page.placeRelative("ABOVE")
                }

                SettingsButton {
                    shell: page.shell
                    Layout.fillWidth: true
                    label: "Below"
                    enabled: page.monitors.length > 1
                        && page.pendingToken.length === 0
                    onClicked: page.placeRelative("BELOW")
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
                        Layout.preferredHeight: 132
                        color: page.selectedIndex === index
                            ? shell.surfaceAlt
                            : monitorMouse.containsMouse
                                ? shell.surfaceHover
                                : shell.backgroundAlt
                        border.width: page.selectedIndex === index
                            ? Math.max(2, shell.borderWidth)
                            : shell.borderWidth
                        border.color: page.selectedIndex === index
                            ? shell.uiPalette[
                                index % shell.uiPalette.length
                            ]
                            : shell.border
                        radius: shell.cardRadius
                        opacity: modelData.disabled === true ? 0.56 : 1

                        ColumnLayout {
                            anchors {
                                fill: parent
                                margins: 14
                            }
                            spacing: 7

                            RowLayout {
                                Layout.fillWidth: true

                                Text {
                                    Layout.fillWidth: true
                                    text: monitorCard.modelData.name
                                    color: shell.textStrong
                                    font.family:
                                        "JetBrainsMono Nerd Font"
                                    font.pixelSize: Math.round(
                                        12 * shell.fontScale
                                    )
                                    font.weight: Font.Black
                                }

                                Text {
                                    text: monitorCard.modelData.disabled
                                        ? "DISABLED"
                                        : monitorCard.modelData.focused
                                            ? "FOCUSED"
                                            : "OUTPUT"
                                    color: monitorCard.modelData.disabled
                                        ? shell.error
                                        : monitorCard.modelData.focused
                                            ? shell.success
                                            : shell.dim
                                    font.family:
                                        "JetBrainsMono Nerd Font"
                                    font.pixelSize: Math.round(
                                        8 * shell.fontScale
                                    )
                                    font.weight: Font.Black
                                }
                            }

                            Text {
                                Layout.fillWidth: true
                                text: (
                                    monitorCard.modelData.model
                                    || monitorCard.modelData.description
                                    || "CONNECTED MONITOR"
                                ).toUpperCase()
                                color: shell.muted
                                elide: Text.ElideRight
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: Math.round(
                                    8 * shell.fontScale
                                )
                                font.weight: Font.Bold
                            }

                            Text {
                                Layout.fillWidth: true
                                text: monitorCard.modelData.width
                                    + "×"
                                    + monitorCard.modelData.height
                                    + " @ "
                                    + Number(
                                        monitorCard.modelData.refreshRate
                                            || 0
                                    ).toFixed(2)
                                    + " HZ  //  "
                                    + Number(
                                        monitorCard.modelData.scale || 1
                                    ).toFixed(2)
                                    + "×"
                                color: shell.uiPalette[
                                    index % shell.uiPalette.length
                                ]
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: Math.round(
                                    9 * shell.fontScale
                                )
                                font.weight: Font.Black
                            }

                            Text {
                                Layout.fillWidth: true
                                text: "POSITION "
                                    + monitorCard.modelData.x
                                    + ","
                                    + monitorCard.modelData.y
                                    + "  //  WORKSPACE "
                                    + (
                                        monitorCard.modelData.activeWorkspace
                                            ? monitorCard.modelData
                                                .activeWorkspace.name
                                            : "—"
                                    )
                                color: shell.dim
                                elide: Text.ElideRight
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: Math.round(
                                    7 * shell.fontScale
                                )
                                font.weight: Font.Bold
                            }
                        }

                        MouseArea {
                            id: monitorMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            enabled: page.pendingToken.length === 0
                            onClicked: page.selectMonitor(
                                monitorCard.index
                            )
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
                enabled: page.pendingToken.length === 0
                onToggled: value => page.editEnabled = value
            }

            SettingsCycle {
                shell: page.shell
                Layout.fillWidth: true
                label: "Resolution"
                options: page.resolutionOptions
                current: page.editResolution
                accent: shell.uiPalette[4]
                enabled: page.editEnabled
                    && page.pendingToken.length === 0
                opacity: enabled ? 1 : 0.46
                onOptionSelected: value => {
                    page.editResolution = value
                    var refreshes = page.refreshOptions
                    if (refreshes.indexOf(page.editRefresh) < 0) {
                        page.editRefresh = refreshes.length > 0
                            ? String(refreshes[0])
                            : ""
                    }
                }
            }

            SettingsCycle {
                shell: page.shell
                Layout.fillWidth: true
                label: "Refresh rate"
                options: page.refreshOptions
                current: page.editRefresh
                accent: shell.uiPalette[2]
                enabled: page.editEnabled
                    && page.pendingToken.length === 0
                opacity: enabled ? 1 : 0.46
                onOptionSelected: value => page.editRefresh = value
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
                enabled: page.editEnabled
                    && page.pendingToken.length === 0
                opacity: enabled ? 1 : 0.46
                onValueSelected: next => page.editScale = next
            }

            SettingsChoice {
                shell: page.shell
                Layout.fillWidth: true
                label: "Rotation"
                options: ["NORMAL", "90", "180", "270"]
                current: page.transformLabel(page.editTransform)
                accent: shell.uiPalette[6]
                enabled: page.editEnabled
                    && page.pendingToken.length === 0
                opacity: enabled ? 1 : 0.46
                onOptionSelected: value => {
                    page.editTransform = page.transformValue(value)
                }
            }

            SettingsToggle {
                shell: page.shell
                Layout.fillWidth: true
                label: "Adaptive sync / VRR"
                checked: page.editVrr
                accent: shell.uiPalette[4]
                enabled: page.editEnabled
                    && page.pendingToken.length === 0
                opacity: enabled ? 1 : 0.46
                onToggled: value => page.editVrr = value
            }

            SettingsStepper {
                shell: page.shell
                Layout.fillWidth: true
                label: "Horizontal position"
                value: page.editX
                minimum: -16384
                maximum: 16384
                step: 10
                suffix: "px"
                accent: shell.uiPalette[1]
                enabled: page.editEnabled
                    && page.pendingToken.length === 0
                opacity: enabled ? 1 : 0.46
                onValueSelected: next => {
                    page.editX = Math.round(next)
                }
            }

            SettingsStepper {
                shell: page.shell
                Layout.fillWidth: true
                label: "Vertical position"
                value: page.editY
                minimum: -16384
                maximum: 16384
                step: 10
                suffix: "px"
                accent: shell.uiPalette[2]
                enabled: page.editEnabled
                    && page.pendingToken.length === 0
                opacity: enabled ? 1 : 0.46
                onValueSelected: next => {
                    page.editY = Math.round(next)
                }
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
                    enabled: !page.busy
                        && page.pendingToken.length === 0
                        && (!page.editEnabled
                            || page.editMode.length > 0)
                    onClicked: page.preview()
                }

                SettingsButton {
                    shell: page.shell
                    label: "Focus"
                    accent: shell.uiPalette[3]
                    enabled: !page.busy
                        && page.editEnabled
                        && page.pendingToken.length === 0
                    onClicked: {
                        page.busy = true
                        actionProcess.exec([
                            "bash",
                            Quickshell.shellPath(
                                "backend/chroma-settingsctl"
                            ),
                            "display-focus",
                            page.selectedName
                        ])
                    }
                }

                SettingsButton {
                    shell: page.shell
                    label: "Refresh"
                    accent: shell.uiPalette[4]
                    enabled: !page.busy
                        && page.pendingToken.length === 0
                    onClicked: page.refresh()
                }
            }
        }

        SettingsCard {
            shell: page.shell
            Layout.fillWidth: true
            title: "Recovery and persistence"
            accent: shell.uiPalette[1]

            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                SettingsButton {
                    shell: page.shell
                    Layout.fillWidth: true
                    label: "Save current"
                    sublabel: "Known-good"
                    accent: shell.success
                    enabled: !page.busy
                        && page.pendingToken.length === 0
                    onClicked: {
                        page.busy = true
                        actionProcess.exec([
                            "bash",
                            Quickshell.shellPath(
                                "backend/chroma-settingsctl"
                            ),
                            "display-known-good"
                        ])
                    }
                }

                SettingsButton {
                    shell: page.shell
                    Layout.fillWidth: true
                    label: "Restore"
                    sublabel: "Known-good"
                    accent: shell.warning
                    enabled: !page.busy
                        && page.pendingToken.length === 0
                    onClicked: {
                        page.busy = true
                        actionProcess.exec([
                            "bash",
                            Quickshell.shellPath(
                                "backend/chroma-settingsctl"
                            ),
                            "display-restore-known-good"
                        ])
                    }
                }

                SettingsButton {
                    shell: page.shell
                    label: "Open config"
                    accent: shell.uiPalette[4]
                    onClicked: Quickshell.execDetached([
                        "bash",
                        Quickshell.shellPath(
                            "backend/chroma-settingsctl"
                        ),
                        "open-display-config"
                    ])
                }

                SettingsButton {
                    shell: page.shell
                    label: "Copy report"
                    accent: shell.uiPalette[6]
                    onClicked: Quickshell.execDetached([
                        "bash",
                        Quickshell.shellPath(
                            "backend/chroma-settingsctl"
                        ),
                        "copy-monitors"
                    ])
                }
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

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

Scope {
    id: component

    required property var shell
    required property var settings

    property string query: ""
    property var entries: []
    property var inspectedEntry: ({})
    property bool dependenciesReady: false
    property bool capabilitiesChecked: false
    property bool busy: false
    property bool pendingPaste: false
    property bool clearArmed: false
    property string statusMessage: "INITIALISING CLIPBOARD CHANNEL"

    readonly property string backendPath:
        Quickshell.shellPath("backend/chroma-clipboardctl")

    readonly property bool captureEnabled:
        capabilitiesChecked
        && dependenciesReady
        && !settings.clipboardPrivate

    function selectedEntry() {
        if (
            clipboardList.currentIndex < 0
            || clipboardList.currentIndex >= entries.length
        ) {
            return null
        }

        return entries[clipboardList.currentIndex]
    }

    function syncCaptureProcesses() {
        textWatcher.running = captureEnabled
        imageWatcher.running = captureEnabled
    }

    function refresh() {
        if (!dependenciesReady || refreshProcess.running) {
            return
        }

        busy = true
        refreshProcess.exec([
            "bash",
            backendPath,
            "list",
            query,
            String(settings.clipboardLimit)
        ])
    }

    function inspectCurrent() {
        var entry = selectedEntry()

        if (!entry) {
            inspectedEntry = ({})
            return
        }

        inspectProcess.exec([
            "bash",
            backendPath,
            "inspect",
            entry.id,
            entry.kind
        ])
    }

    function moveSelection(delta) {
        if (clipboardList.count <= 0) {
            return
        }

        var next = clipboardList.currentIndex + delta

        if (next < 0) {
            next = clipboardList.count - 1
        } else if (next >= clipboardList.count) {
            next = 0
        }

        clipboardList.currentIndex = next
        clipboardList.positionViewAtIndex(next, ListView.Contain)
    }

    function restoreEntry(pasteAfter) {
        var entry = selectedEntry()

        if (!entry || copyProcess.running) {
            return
        }

        pendingPaste = pasteAfter
        busy = true
        statusMessage = pasteAfter
            ? "RESTORING AND PASTING ENTRY"
            : "RESTORING ENTRY"

        copyProcess.exec([
            "bash",
            backendPath,
            "copy",
            entry.id
        ])
    }

    function deleteCurrent() {
        var entry = selectedEntry()

        if (!entry || deleteProcess.running) {
            return
        }

        busy = true
        deleteProcess.exec([
            "bash",
            backendPath,
            "delete",
            entry.id
        ])
    }

    function requestClear() {
        if (!clearArmed) {
            clearArmed = true
            clearArmTimer.restart()
            statusMessage = "PRESS CLEAR AGAIN TO WIPE HISTORY"
            return
        }

        clearArmed = false
        busy = true
        clearProcess.exec([
            "bash",
            backendPath,
            "clear"
        ])
    }

    function togglePrivate() {
        settings.clipboardPrivate = !settings.clipboardPrivate
        settings.scheduleSave()
        syncCaptureProcesses()

        statusMessage = settings.clipboardPrivate
            ? "PRIVATE MODE ENABLED // CAPTURE PAUSED"
            : "PRIVATE MODE DISABLED // CAPTURE ACTIVE"
    }

    Process {
        id: capabilitiesProcess
        command: ["bash", component.backendPath, "capabilities"]

        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    var result = JSON.parse(text)
                    component.dependenciesReady = result.ok === true
                    component.statusMessage = component.dependenciesReady
                        ? "CLIPBOARD CHANNEL READY"
                        : "CLIPHIST / WAYLAND CLIPBOARD TOOLS ARE MISSING"
                } catch (error) {
                    component.dependenciesReady = false
                    component.statusMessage = "CLIPBOARD CAPABILITY REPORT FAILED"
                }

                component.capabilitiesChecked = true
                component.syncCaptureProcesses()
            }
        }

        stderr: StdioCollector {
            onStreamFinished: {
                if (text.trim().length > 0) {
                    component.statusMessage = text.trim()
                }
            }
        }
    }

    Process {
        id: textWatcher
        command: ["bash", component.backendPath, "watch-text"]

        onExited: {
            if (component.captureEnabled) {
                textWatcherRestart.restart()
            }
        }
    }

    Process {
        id: imageWatcher
        command: ["bash", component.backendPath, "watch-image"]

        onExited: {
            if (component.captureEnabled) {
                imageWatcherRestart.restart()
            }
        }
    }

    Timer {
        id: textWatcherRestart
        interval: 1200
        repeat: false
        onTriggered: {
            if (component.captureEnabled) {
                textWatcher.running = true
            }
        }
    }

    Timer {
        id: imageWatcherRestart
        interval: 1200
        repeat: false
        onTriggered: {
            if (component.captureEnabled) {
                imageWatcher.running = true
            }
        }
    }

    Process {
        id: refreshProcess

        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    var result = JSON.parse(text)
                    component.entries = result.entries || []
                    clipboardList.currentIndex = component.entries.length > 0
                        ? 0
                        : -1
                    component.statusMessage = component.entries.length
                        + " CLIPBOARD ENTRIES INDEXED"
                    component.inspectCurrent()
                } catch (error) {
                    component.entries = []
                    component.inspectedEntry = ({})
                    component.statusMessage = "CLIPBOARD HISTORY COULD NOT BE PARSED"
                }

                component.busy = false
            }
        }

        stderr: StdioCollector {
            onStreamFinished: {
                if (text.trim().length > 0) {
                    component.statusMessage = text.trim()
                }
                component.busy = false
            }
        }
    }

    Process {
        id: inspectProcess

        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    var result = JSON.parse(text)
                    component.inspectedEntry = result.ok === true
                        ? result
                        : ({})
                } catch (error) {
                    component.inspectedEntry = ({})
                }
            }
        }
    }

    Process {
        id: copyProcess

        stdout: StdioCollector {
            onStreamFinished: {
                var ok = false

                try {
                    var result = JSON.parse(text)
                    ok = result.ok === true
                    component.statusMessage = result.message || "ENTRY RESTORED"
                } catch (error) {
                    component.statusMessage = text.trim().length > 0
                        ? text.trim()
                        : "CLIPBOARD ENTRY RESTORE FAILED"
                }

                component.busy = false

                if (ok && component.pendingPaste) {
                    component.shell.clipboardOpen = false
                    pasteTimer.restart()
                }

                component.pendingPaste = false
            }
        }

        stderr: StdioCollector {
            onStreamFinished: {
                if (text.trim().length > 0) {
                    component.statusMessage = text.trim()
                }
                component.busy = false
                component.pendingPaste = false
            }
        }
    }

    Process {
        id: deleteProcess

        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    var result = JSON.parse(text)
                    component.statusMessage = result.message || "ENTRY DELETED"
                } catch (error) {
                    component.statusMessage = text.trim()
                }
                component.busy = false
                component.refresh()
            }
        }
    }

    Process {
        id: clearProcess

        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    var result = JSON.parse(text)
                    component.statusMessage = result.message || "HISTORY CLEARED"
                } catch (error) {
                    component.statusMessage = text.trim()
                }
                component.busy = false
                component.refresh()
            }
        }
    }

    Timer {
        id: pasteTimer
        interval: 80
        repeat: false
        onTriggered: Quickshell.execDetached([
            "bash",
            component.backendPath,
            "send-paste"
        ])
    }

    Timer {
        id: clearArmTimer
        interval: 4200
        repeat: false
        onTriggered: component.clearArmed = false
    }

    Timer {
        id: searchTimer
        interval: 140
        repeat: false
        onTriggered: component.refresh()
    }

    Timer {
        interval: 1300
        repeat: true
        running: component.shell.clipboardOpen
        onTriggered: component.refresh()
    }

    Timer {
        id: focusTimer
        interval: 45
        repeat: false
        onTriggered: {
            searchInput.forceActiveFocus()
            searchInput.selectAll()
        }
    }

    Connections {
        target: component.shell

        function onClipboardOpenChanged() {
            if (component.shell.clipboardOpen) {
                component.query = ""
                searchInput.text = ""
                component.refresh()
                focusTimer.restart()
            }
        }
    }

    Connections {
        target: component.settings

        function onClipboardPrivateChanged() {
            component.syncCaptureProcesses()
        }
    }

    ScriptModel {
        id: clipboardModel
        values: component.entries
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: clipboardWindow

            required property var modelData

            screen: modelData
            visible:
                modelData.name === component.shell.resolvedBarMonitor
                && component.shell.clipboardOpen

            anchors {
                top: true
                bottom: true
                left: true
                right: true
            }

            exclusiveZone: 0
            aboveWindows: true
            focusable: component.shell.clipboardOpen
            color: "transparent"

            WlrLayershell.namespace: "chroma-clipboard"
            WlrLayershell.keyboardFocus:
                component.shell.clipboardOpen
                    ? WlrKeyboardFocus.Exclusive
                    : WlrKeyboardFocus.None

            Rectangle {
                anchors.fill: parent
                color: "#44000000"

                MouseArea {
                    anchors.fill: parent
                    onClicked: component.shell.clipboardOpen = false
                }
            }

            Rectangle {
                id: panel

                width: Math.min(980, clipboardWindow.width - 80)
                height: Math.min(660, clipboardWindow.height - 110)

                anchors.centerIn: parent

                color: component.shell.backgroundAlt
                border.width: component.shell.borderWidth
                border.color: searchInput.activeFocus
                    ? component.shell.uiPalette[4]
                    : component.shell.border
                radius: component.shell.panelRadius
                clip: true

                Rectangle {
                    x: component.shell.panelRadius > 4
                        ? Math.max(8, Math.round(component.shell.panelRadius * 0.6))
                        : 0
                    y: component.shell.panelRadius > 4
                        ? Math.max(9, Math.round(component.shell.panelRadius * 0.7))
                        : 0
                    width: 4
                    height: component.shell.panelRadius > 4
                        ? panel.height - y * 2
                        : panel.height
                    radius: component.shell.panelRadius > 4 ? 2 : 0
                    color: component.shell.uiPalette[4]
                }

                ColumnLayout {
                    anchors {
                        fill: parent
                        margins: 18
                        leftMargin: component.shell.panelRadius > 4 ? 34 : 22
                    }
                    spacing: 12

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 12

                        Rectangle {
                            Layout.preferredWidth: 42
                            Layout.preferredHeight: 42
                            color: component.shell.uiPalette[4]
                            radius: component.shell.controlRadius

                            Text {
                                anchors.centerIn: parent
                                text: "󰅌"
                                color: component.shell.ink
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: Math.round(20 * component.shell.fontScale)
                                font.weight: Font.Black
                            }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 2

                            Text {
                                text: "CHROMA//CLIPBOARD"
                                color: component.shell.textStrong
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: Math.round(16 * component.shell.fontScale)
                                font.weight: Font.Black
                                font.letterSpacing: 1
                            }

                            Text {
                                text: component.statusMessage
                                color: component.settings.clipboardPrivate
                                    ? component.shell.warning
                                    : component.shell.muted
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: Math.round(7 * component.shell.fontScale)
                                font.weight: Font.Bold
                                font.letterSpacing: 0.8
                                elide: Text.ElideRight
                                Layout.fillWidth: true
                            }
                        }

                        Rectangle {
                            Layout.preferredWidth: 126
                            Layout.preferredHeight: 38
                            color: component.settings.clipboardPrivate
                                ? component.shell.warning
                                : component.shell.surface
                            border.width: component.shell.borderWidth
                            border.color: component.settings.clipboardPrivate
                                ? component.shell.warning
                                : component.shell.border
                            radius: component.shell.controlRadius

                            Text {
                                anchors.centerIn: parent
                                text: component.settings.clipboardPrivate
                                    ? "PRIVATE // ON"
                                    : "PRIVATE // OFF"
                                color: component.settings.clipboardPrivate
                                    ? component.shell.ink
                                    : component.shell.text
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: Math.round(8 * component.shell.fontScale)
                                font.weight: Font.Black
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: component.togglePrivate()
                            }
                        }

                        Rectangle {
                            Layout.preferredWidth: 42
                            Layout.preferredHeight: 38
                            color: closeMouse.containsMouse
                                ? component.shell.error
                                : component.shell.surface
                            border.width: component.shell.borderWidth
                            border.color: closeMouse.containsMouse
                                ? component.shell.error
                                : component.shell.border
                            radius: component.shell.controlRadius

                            Text {
                                anchors.centerIn: parent
                                text: "×"
                                color: closeMouse.containsMouse
                                    ? component.shell.ink
                                    : component.shell.text
                                font.pixelSize: Math.round(22 * component.shell.fontScale)
                                font.weight: Font.Black
                            }

                            MouseArea {
                                id: closeMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: component.shell.clipboardOpen = false
                            }
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 48
                        color: component.shell.surface
                        border.width: component.shell.borderWidth
                        border.color: searchInput.activeFocus
                            ? component.shell.uiPalette[4]
                            : component.shell.border
                        radius: component.shell.controlRadius

                        RowLayout {
                            anchors {
                                fill: parent
                                leftMargin: 14
                                rightMargin: 14
                            }
                            spacing: 10

                            Text {
                                text: "⌕"
                                color: component.shell.uiPalette[4]
                                font.pixelSize: Math.round(20 * component.shell.fontScale)
                                font.weight: Font.Black
                            }

                            TextInput {
                                id: searchInput

                                Layout.fillWidth: true
                                color: component.shell.text
                                selectionColor: component.shell.uiPalette[4]
                                selectedTextColor: component.shell.ink
                                clip: true

                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: Math.round(11 * component.shell.fontScale)
                                font.weight: Font.Bold

                                onTextChanged: {
                                    component.query = text
                                    searchTimer.restart()
                                }

                                Keys.onPressed: function(event) {
                                    if (event.key === Qt.Key_Escape) {
                                        component.shell.clipboardOpen = false
                                        event.accepted = true
                                    } else if (event.key === Qt.Key_Up) {
                                        component.moveSelection(-1)
                                        event.accepted = true
                                    } else if (event.key === Qt.Key_Down) {
                                        component.moveSelection(1)
                                        event.accepted = true
                                    } else if (
                                        event.key === Qt.Key_Return
                                        || event.key === Qt.Key_Enter
                                    ) {
                                        component.restoreEntry(
                                            (event.modifiers & Qt.ControlModifier) === 0
                                        )
                                        event.accepted = true
                                    } else if (
                                        event.key === Qt.Key_Delete
                                        && text.length === 0
                                    ) {
                                        component.deleteCurrent()
                                        event.accepted = true
                                    }
                                }
                            }

                            Text {
                                visible: searchInput.text.length === 0
                                text: "SEARCH TEXT OR IMAGE HISTORY"
                                color: component.shell.dim
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: Math.round(8 * component.shell.fontScale)
                                font.weight: Font.Bold
                            }
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        spacing: 12

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            Layout.preferredWidth: 5
                            color: component.shell.surface
                            border.width: component.shell.borderWidth
                            border.color: component.shell.border
                            radius: component.shell.cardRadius
                            clip: true

                            ListView {
                                id: clipboardList
                                anchors.fill: parent
                                anchors.margins: 8
                                spacing: 6
                                clip: true
                                model: clipboardModel
                                currentIndex: -1

                                onCurrentIndexChanged: component.inspectCurrent()

                                delegate: Rectangle {
                                    id: entryRow

                                    required property var modelData
                                    property var entry: modelData

                                    width: ListView.view.width
                                    height: 68
                                    color: ListView.isCurrentItem
                                        ? component.shell.surfaceHover
                                        : entryMouse.containsMouse
                                            ? component.shell.surfaceAlt
                                            : component.shell.backgroundAlt
                                    border.width: component.shell.borderWidth
                                    border.color: ListView.isCurrentItem
                                        ? component.shell.uiPalette[index % component.shell.uiPalette.length]
                                        : component.shell.border
                                    radius: component.shell.cardRadius

                                    RowLayout {
                                        anchors {
                                            fill: parent
                                            margins: 10
                                        }
                                        spacing: 10

                                        Rectangle {
                                            Layout.preferredWidth: 42
                                            Layout.preferredHeight: 42
                                            color: entryRow.entry.kind === "image"
                                                ? component.shell.uiPalette[5]
                                                : component.shell.uiPalette[3]
                                            radius: component.shell.controlRadius

                                            Text {
                                                anchors.centerIn: parent
                                                text: entryRow.entry.kind === "image"
                                                    ? "IMG"
                                                    : "TXT"
                                                color: component.shell.ink
                                                font.family: "JetBrainsMono Nerd Font"
                                                font.pixelSize: Math.round(8 * component.shell.fontScale)
                                                font.weight: Font.Black
                                            }
                                        }

                                        ColumnLayout {
                                            Layout.fillWidth: true
                                            spacing: 3

                                            Text {
                                                Layout.fillWidth: true
                                                text: entryRow.entry.kind === "image"
                                                    ? entryRow.entry.detail
                                                    : entryRow.entry.preview
                                                color: component.shell.text
                                                font.family: "JetBrainsMono Nerd Font"
                                                font.pixelSize: Math.round(9 * component.shell.fontScale)
                                                font.weight: Font.Bold
                                                elide: Text.ElideRight
                                            }

                                            Text {
                                                Layout.fillWidth: true
                                                text: "ENTRY " + entryRow.entry.id
                                                    + " // " + entryRow.entry.mime.toUpperCase()
                                                color: component.shell.muted
                                                font.family: "JetBrainsMono Nerd Font"
                                                font.pixelSize: Math.round(7 * component.shell.fontScale)
                                                font.weight: Font.Bold
                                                elide: Text.ElideRight
                                            }
                                        }
                                    }

                                    MouseArea {
                                        id: entryMouse
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: clipboardList.currentIndex = index
                                        onDoubleClicked: {
                                            clipboardList.currentIndex = index
                                            component.restoreEntry(true)
                                        }
                                    }
                                }
                            }

                            ColumnLayout {
                                anchors.centerIn: parent
                                visible: component.entries.length === 0
                                spacing: 8

                                Text {
                                    Layout.alignment: Qt.AlignHCenter
                                    text: component.dependenciesReady ? "󰅇" : "!"
                                    color: component.shell.uiPalette[4]
                                    font.family: "JetBrainsMono Nerd Font"
                                    font.pixelSize: 34
                                    font.weight: Font.Black
                                }

                                Text {
                                    Layout.alignment: Qt.AlignHCenter
                                    text: component.dependenciesReady
                                        ? "NO CLIPBOARD ENTRIES"
                                        : "CLIPBOARD TOOLS UNAVAILABLE"
                                    color: component.shell.text
                                    font.family: "JetBrainsMono Nerd Font"
                                    font.pixelSize: Math.round(10 * component.shell.fontScale)
                                    font.weight: Font.Black
                                }
                            }
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            Layout.preferredWidth: 4
                            color: component.shell.surface
                            border.width: component.shell.borderWidth
                            border.color: component.shell.border
                            radius: component.shell.cardRadius
                            clip: true

                            ColumnLayout {
                                anchors {
                                    fill: parent
                                    margins: 14
                                }
                                spacing: 10

                                RowLayout {
                                    Layout.fillWidth: true

                                    Text {
                                        Layout.fillWidth: true
                                        text: "ENTRY PREVIEW"
                                        color: component.shell.textStrong
                                        font.family: "JetBrainsMono Nerd Font"
                                        font.pixelSize: Math.round(10 * component.shell.fontScale)
                                        font.weight: Font.Black
                                        font.letterSpacing: 1
                                    }

                                    Text {
                                        text: component.selectedEntry()
                                            ? "#" + component.selectedEntry().id
                                            : "—"
                                        color: component.shell.uiPalette[4]
                                        font.family: "JetBrainsMono Nerd Font"
                                        font.pixelSize: Math.round(8 * component.shell.fontScale)
                                        font.weight: Font.Black
                                    }
                                }

                                Rectangle {
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    color: component.shell.backgroundAlt
                                    border.width: component.shell.borderWidth
                                    border.color: component.shell.border
                                    radius: component.shell.cardRadius
                                    clip: true

                                    Image {
                                        anchors {
                                            fill: parent
                                            margins: 12
                                        }
                                        visible: component.inspectedEntry.kind === "image"
                                        source: component.inspectedEntry.path || ""
                                        fillMode: Image.PreserveAspectFit
                                        asynchronous: true
                                        cache: false
                                    }

                                    Flickable {
                                        anchors {
                                            fill: parent
                                            margins: 12
                                        }
                                        visible: component.inspectedEntry.kind === "text"
                                        contentWidth: width
                                        contentHeight: previewText.implicitHeight
                                        clip: true

                                        Text {
                                            id: previewText
                                            width: parent.width
                                            text: component.inspectedEntry.text || ""
                                            color: component.shell.text
                                            wrapMode: Text.WrapAnywhere
                                            font.family: "JetBrainsMono Nerd Font"
                                            font.pixelSize: Math.round(9 * component.shell.fontScale)
                                            font.weight: Font.Medium
                                        }
                                    }

                                    Text {
                                        anchors.centerIn: parent
                                        visible: !component.inspectedEntry.kind
                                        text: "SELECT AN ENTRY"
                                        color: component.shell.dim
                                        font.family: "JetBrainsMono Nerd Font"
                                        font.pixelSize: Math.round(9 * component.shell.fontScale)
                                        font.weight: Font.Black
                                    }
                                }
                            }
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8

                        Text {
                            Layout.fillWidth: true
                            text: "ENTER PASTE  //  CTRL+ENTER COPY  //  DELETE REMOVE  //  ESC CLOSE"
                            color: component.shell.dim
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: Math.round(7 * component.shell.fontScale)
                            font.weight: Font.Bold
                            elide: Text.ElideRight
                        }

                        Rectangle {
                            Layout.preferredWidth: 86
                            Layout.preferredHeight: 36
                            color: copyMouse.containsMouse
                                ? component.shell.uiPalette[3]
                                : component.shell.surface
                            border.width: component.shell.borderWidth
                            border.color: copyMouse.containsMouse
                                ? component.shell.uiPalette[3]
                                : component.shell.border
                            radius: component.shell.controlRadius

                            Text {
                                anchors.centerIn: parent
                                text: "COPY"
                                color: copyMouse.containsMouse
                                    ? component.shell.ink
                                    : component.shell.text
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: Math.round(8 * component.shell.fontScale)
                                font.weight: Font.Black
                            }

                            MouseArea {
                                id: copyMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: component.restoreEntry(false)
                            }
                        }

                        Rectangle {
                            Layout.preferredWidth: 86
                            Layout.preferredHeight: 36
                            color: pasteMouse.containsMouse
                                ? component.shell.uiPalette[4]
                                : component.shell.surface
                            border.width: component.shell.borderWidth
                            border.color: pasteMouse.containsMouse
                                ? component.shell.uiPalette[4]
                                : component.shell.border
                            radius: component.shell.controlRadius

                            Text {
                                anchors.centerIn: parent
                                text: "PASTE"
                                color: pasteMouse.containsMouse
                                    ? component.shell.ink
                                    : component.shell.text
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: Math.round(8 * component.shell.fontScale)
                                font.weight: Font.Black
                            }

                            MouseArea {
                                id: pasteMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: component.restoreEntry(true)
                            }
                        }

                        Rectangle {
                            Layout.preferredWidth: 86
                            Layout.preferredHeight: 36
                            color: deleteMouse.containsMouse
                                ? component.shell.error
                                : component.shell.surface
                            border.width: component.shell.borderWidth
                            border.color: deleteMouse.containsMouse
                                ? component.shell.error
                                : component.shell.border
                            radius: component.shell.controlRadius

                            Text {
                                anchors.centerIn: parent
                                text: "DELETE"
                                color: deleteMouse.containsMouse
                                    ? component.shell.ink
                                    : component.shell.text
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: Math.round(8 * component.shell.fontScale)
                                font.weight: Font.Black
                            }

                            MouseArea {
                                id: deleteMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: component.deleteCurrent()
                            }
                        }

                        Rectangle {
                            Layout.preferredWidth: 106
                            Layout.preferredHeight: 36
                            color: component.clearArmed
                                ? component.shell.error
                                : clearMouse.containsMouse
                                    ? component.shell.warning
                                    : component.shell.surface
                            border.width: component.shell.borderWidth
                            border.color: component.clearArmed
                                ? component.shell.error
                                : clearMouse.containsMouse
                                    ? component.shell.warning
                                    : component.shell.border
                            radius: component.shell.controlRadius

                            Text {
                                anchors.centerIn: parent
                                text: component.clearArmed ? "CONFIRM" : "CLEAR ALL"
                                color: component.clearArmed || clearMouse.containsMouse
                                    ? component.shell.ink
                                    : component.shell.text
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: Math.round(8 * component.shell.fontScale)
                                font.weight: Font.Black
                            }

                            MouseArea {
                                id: clearMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: component.requestClear()
                            }
                        }
                    }
                }
            }
        }
    }

    Component.onCompleted: capabilitiesProcess.running = true
}

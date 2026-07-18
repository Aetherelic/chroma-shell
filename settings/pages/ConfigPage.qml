import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import "../components"

Flickable {
    id: page

    required property var shell
    required property var settings

    property var status: ({
        git: { branch: "LOADING", commit: "—", remote: "—", dirty: 0 },
        runtime: {
            instances: 0,
            errors: 0,
            warnings: 0,
            quickshell: "—",
            hyprland: "—"
        },
        configuration: {
            settingsValid: false,
            backendValid: false,
            stylePreset: "—",
            colourTreatment: "—"
        },
        files: []
    })
    property var snapshots: []
    property string selectedSnapshot: ""
    property string importPath: ""
    property string output: "READY // CONFIGURATION CENTRE ONLINE"
    property bool busy: false
    property bool refreshAfterAction: false
    property string armedAction: ""
    property string armedTarget: ""

    readonly property var selectedSnapshotData: {
        for (var index = 0; index < snapshots.length; index++) {
            if (snapshots[index].id === selectedSnapshot) {
                return snapshots[index]
            }
        }
        return null
    }

    contentWidth: width
    contentHeight: content.implicitHeight + 28
    clip: true

    function backendCommand(argumentsList) {
        var command = [
            "bash",
            Quickshell.shellPath("backend/chroma-settingsctl")
        ]

        for (var index = 0; index < argumentsList.length; index++) {
            command.push(String(argumentsList[index]))
        }

        return command
    }

    function formatBytes(bytes) {
        var value = Number(bytes || 0)
        if (value >= 1073741824) {
            return (value / 1073741824).toFixed(2) + " GiB"
        }
        if (value >= 1048576) {
            return (value / 1048576).toFixed(1) + " MiB"
        }
        if (value >= 1024) {
            return (value / 1024).toFixed(1) + " KiB"
        }
        return value + " B"
    }

    function formatDate(value) {
        var text = String(value || "")
        if (text.length === 0) {
            return "UNKNOWN TIME"
        }
        return text.replace("T", " ").replace(/\+.*/, "")
    }

    function refreshStatus() {
        statusProcess.exec(backendCommand(["config-status-json"]))
    }

    function refreshSnapshots() {
        snapshotsProcess.exec(backendCommand(["snapshots-json"]))
    }

    function refreshAll() {
        refreshStatus()
        refreshSnapshots()
    }

    function runAction(argumentsList, shouldRefresh) {
        if (busy) {
            return
        }

        busy = true
        refreshAfterAction = shouldRefresh === true
        output = "RUNNING // " + String(argumentsList[0]).toUpperCase()
        actionProcess.exec(backendCommand(argumentsList))
    }

    function clearArm() {
        armedAction = ""
        armedTarget = ""
        armTimer.stop()
    }

    function confirmAction(kind, target, argumentsList) {
        if (target.length === 0) {
            output = "SELECT A SNAPSHOT FIRST"
            return
        }

        if (armedAction === kind && armedTarget === target) {
            clearArm()
            runAction(argumentsList, true)
            return
        }

        armedAction = kind
        armedTarget = target
        output = "PRESS AGAIN TO CONFIRM " + kind.toUpperCase()
        armTimer.restart()
    }

    Component.onCompleted: refreshAll()

    Timer {
        id: armTimer
        interval: 8000
        repeat: false
        onTriggered: page.clearArm()
    }

    Process {
        id: statusProcess

        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    page.status = JSON.parse(text)
                } catch (error) {
                    page.output = "STATUS REPORT COULD NOT BE PARSED"
                }
            }
        }

        stderr: StdioCollector {
            onStreamFinished: {
                if (text.trim().length > 0) {
                    page.output = text.trim()
                }
            }
        }
    }

    Process {
        id: snapshotsProcess

        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    var result = JSON.parse(text)
                    page.snapshots = result

                    var selectedStillExists = false
                    for (var index = 0; index < result.length; index++) {
                        if (result[index].id === page.selectedSnapshot) {
                            selectedStillExists = true
                            break
                        }
                    }

                    if (!selectedStillExists) {
                        page.selectedSnapshot = result.length > 0
                            ? result[0].id
                            : ""
                    }
                } catch (error) {
                    page.output = "SNAPSHOT INDEX COULD NOT BE PARSED"
                }
            }
        }

        stderr: StdioCollector {
            onStreamFinished: {
                if (text.trim().length > 0) {
                    page.output = text.trim()
                }
            }
        }
    }

    Process {
        id: actionProcess

        stdout: StdioCollector {
            onStreamFinished: {
                page.output = text.trim().length > 0
                    ? text.trim()
                    : "ACTION COMPLETED"
                page.busy = false

                if (page.refreshAfterAction) {
                    page.refreshAll()
                }
            }
        }

        stderr: StdioCollector {
            onStreamFinished: {
                if (text.trim().length > 0) {
                    page.output = text.trim()
                }
                page.busy = false
            }
        }
    }

    ColumnLayout {
        id: content
        width: page.width
        spacing: 16

        PageHeader {
            shell: page.shell
            index: "06"
            title: "Config"
        }

        SettingsCard {
            shell: page.shell
            Layout.fillWidth: true
            title: "System state"
            accent: shell.uiPalette[4]

            GridLayout {
                Layout.fillWidth: true
                columns: 2
                columnSpacing: 28
                rowSpacing: 4

                InfoRow {
                    shell: page.shell
                    Layout.fillWidth: true
                    label: "Git branch"
                    value: page.status.git.branch || "—"
                    valueColor: shell.uiPalette[4]
                }

                InfoRow {
                    shell: page.shell
                    Layout.fillWidth: true
                    label: "Commit"
                    value: page.status.git.commit || "—"
                }

                InfoRow {
                    shell: page.shell
                    Layout.fillWidth: true
                    label: "Worktree"
                    value: Number(page.status.git.dirty || 0) === 0
                        ? "CLEAN"
                        : page.status.git.dirty + " CHANGES"
                    valueColor: Number(page.status.git.dirty || 0) === 0
                        ? shell.success
                        : shell.warning
                }

                InfoRow {
                    shell: page.shell
                    Layout.fillWidth: true
                    label: "Runtime"
                    value: page.status.runtime.instances + " INSTANCE(S)"
                    valueColor: Number(page.status.runtime.instances || 0) === 1
                        ? shell.success
                        : shell.warning
                }

                InfoRow {
                    shell: page.shell
                    Layout.fillWidth: true
                    label: "Settings JSON"
                    value: page.status.configuration.settingsValid
                        ? "VALID"
                        : "INVALID"
                    valueColor: page.status.configuration.settingsValid
                        ? shell.success
                        : shell.error
                }

                InfoRow {
                    shell: page.shell
                    Layout.fillWidth: true
                    label: "Backend"
                    value: page.status.configuration.backendValid
                        ? "VALID"
                        : "INVALID"
                    valueColor: page.status.configuration.backendValid
                        ? shell.success
                        : shell.error
                }

                InfoRow {
                    shell: page.shell
                    Layout.fillWidth: true
                    label: "Style"
                    value: page.status.configuration.stylePreset
                        + " // "
                        + page.status.configuration.colourTreatment
                }

                InfoRow {
                    shell: page.shell
                    Layout.fillWidth: true
                    label: "Runtime log"
                    value: page.status.runtime.errors
                        + " ERRORS // "
                        + page.status.runtime.warnings
                        + " WARNINGS"
                    valueColor: Number(page.status.runtime.errors || 0) > 0
                        ? shell.error
                        : (Number(page.status.runtime.warnings || 0) > 0
                            ? shell.warning
                            : shell.success)
                }
            }

            GridLayout {
                Layout.fillWidth: true
                columns: 3
                columnSpacing: 10
                rowSpacing: 10

                SettingsButton {
                    shell: page.shell
                    Layout.fillWidth: true
                    label: "Refresh"
                    accent: shell.uiPalette[4]
                    filled: true
                    enabled: !page.busy
                    onClicked: page.refreshAll()
                }

                SettingsButton {
                    shell: page.shell
                    Layout.fillWidth: true
                    label: "Validate"
                    accent: shell.uiPalette[6]
                    enabled: !page.busy
                    onClicked: page.runAction(["config-validate"], true)
                }

                SettingsButton {
                    shell: page.shell
                    Layout.fillWidth: true
                    label: "Copy report"
                    enabled: !page.busy
                    onClicked: page.runAction(["copy-report"], false)
                }
            }
        }

        SettingsCard {
            shell: page.shell
            Layout.fillWidth: true
            title: "Managed configuration"
            accent: shell.uiPalette[1]

            Repeater {
                model: page.status.files || []

                Rectangle {
                    id: fileRow
                    required property var modelData

                    Layout.fillWidth: true
                    Layout.preferredHeight: 62
                    color: shell.backgroundAlt
                    border.width: shell.borderWidth
                    border.color: modelData.valid
                        ? shell.border
                        : shell.error
                    radius: shell.cardRadius

                    RowLayout {
                        anchors {
                            fill: parent
                            leftMargin: 12
                            rightMargin: 10
                        }
                        spacing: 10

                        Rectangle {
                            Layout.preferredWidth: 8
                            Layout.preferredHeight: 8
                            radius: 99
                            color: !fileRow.modelData.exists
                                ? shell.dim
                                : (fileRow.modelData.valid
                                    ? shell.success
                                    : shell.error)
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 2

                            Text {
                                Layout.fillWidth: true
                                text: fileRow.modelData.label.toUpperCase()
                                color: shell.textStrong
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: Math.round(9 * shell.fontScale)
                                font.weight: Font.Black
                                elide: Text.ElideRight
                            }

                            Text {
                                Layout.fillWidth: true
                                text: fileRow.modelData.path
                                color: shell.muted
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: Math.round(7 * shell.fontScale)
                                font.weight: Font.Bold
                                elide: Text.ElideMiddle
                            }
                        }

                        Text {
                            text: fileRow.modelData.exists
                                ? page.formatBytes(fileRow.modelData.size)
                                : "MISSING"
                            color: fileRow.modelData.exists
                                ? shell.muted
                                : shell.dim
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: Math.round(7 * shell.fontScale)
                            font.weight: Font.Bold
                        }

                        SettingsButton {
                            shell: page.shell
                            Layout.preferredWidth: 82
                            label: "Open"
                            enabled: !page.busy
                            onClicked: page.runAction([
                                "config-open",
                                fileRow.modelData.id
                            ], false)
                        }

                        SettingsButton {
                            shell: page.shell
                            Layout.preferredWidth: 92
                            label: "Copy path"
                            enabled: !page.busy
                            onClicked: page.runAction([
                                "config-copy-path",
                                fileRow.modelData.id
                            ], false)
                        }
                    }
                }
            }
        }

        SettingsCard {
            shell: page.shell
            Layout.fillWidth: true
            title: "Recovery snapshots"
            accent: shell.uiPalette[3]

            GridLayout {
                Layout.fillWidth: true
                columns: 3
                columnSpacing: 10
                rowSpacing: 10

                SettingsButton {
                    shell: page.shell
                    Layout.fillWidth: true
                    label: "Create snapshot"
                    accent: shell.uiPalette[3]
                    filled: true
                    enabled: !page.busy
                    onClicked: page.runAction([
                        "snapshot-create",
                        "manual"
                    ], true)
                }

                SettingsButton {
                    shell: page.shell
                    Layout.fillWidth: true
                    label: "Refresh index"
                    enabled: !page.busy
                    onClicked: page.refreshSnapshots()
                }

                SettingsButton {
                    shell: page.shell
                    Layout.fillWidth: true
                    label: "Open folder"
                    enabled: !page.busy
                    onClicked: page.runAction([
                        "config-open",
                        "snapshots"
                    ], false)
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 8

                Text {
                    visible: page.snapshots.length === 0
                    Layout.fillWidth: true
                    text: "NO SNAPSHOTS CREATED"
                    color: shell.dim
                    horizontalAlignment: Text.AlignHCenter
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: Math.round(9 * shell.fontScale)
                    font.weight: Font.Bold
                }

                Repeater {
                    model: page.snapshots

                    Rectangle {
                        id: snapshotRow
                        required property var modelData

                        Layout.fillWidth: true
                        Layout.preferredHeight: 64
                        color: page.selectedSnapshot === modelData.id
                            ? shell.surfaceHover
                            : shell.backgroundAlt
                        border.width: page.selectedSnapshot === modelData.id
                            ? 2
                            : shell.borderWidth
                        border.color: !modelData.valid
                            ? shell.error
                            : (page.selectedSnapshot === modelData.id
                                ? shell.uiPalette[3]
                                : shell.border)
                        radius: shell.cardRadius

                        RowLayout {
                            anchors {
                                fill: parent
                                leftMargin: 12
                                rightMargin: 12
                            }
                            spacing: 12

                            Rectangle {
                                Layout.preferredWidth: 12
                                Layout.preferredHeight: 12
                                radius: shell.microRadius
                                color: snapshotRow.modelData.valid
                                    ? shell.uiPalette[3]
                                    : shell.error
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 2

                                Text {
                                    Layout.fillWidth: true
                                    text: snapshotRow.modelData.label.toUpperCase()
                                    color: shell.textStrong
                                    font.family: "JetBrainsMono Nerd Font"
                                    font.pixelSize: Math.round(9 * shell.fontScale)
                                    font.weight: Font.Black
                                    elide: Text.ElideRight
                                }

                                Text {
                                    Layout.fillWidth: true
                                    text: snapshotRow.modelData.id
                                    color: shell.muted
                                    font.family: "JetBrainsMono Nerd Font"
                                    font.pixelSize: Math.round(7 * shell.fontScale)
                                    font.weight: Font.Bold
                                    elide: Text.ElideMiddle
                                }
                            }

                            ColumnLayout {
                                spacing: 2

                                Text {
                                    Layout.alignment: Qt.AlignRight
                                    text: page.formatDate(
                                        snapshotRow.modelData.createdAt
                                    )
                                    color: shell.text
                                    font.family: "JetBrainsMono Nerd Font"
                                    font.pixelSize: Math.round(7 * shell.fontScale)
                                    font.weight: Font.Bold
                                }

                                Text {
                                    Layout.alignment: Qt.AlignRight
                                    text: page.formatBytes(snapshotRow.modelData.size)
                                        + (snapshotRow.modelData.git
                                            && snapshotRow.modelData.git.commit
                                            ? " // "
                                                + snapshotRow.modelData.git.commit
                                            : "")
                                    color: shell.muted
                                    font.family: "JetBrainsMono Nerd Font"
                                    font.pixelSize: Math.round(7 * shell.fontScale)
                                    font.weight: Font.Bold
                                }
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                page.selectedSnapshot = snapshotRow.modelData.id
                                page.clearArm()
                            }
                        }
                    }
                }
            }

            GridLayout {
                Layout.fillWidth: true
                columns: 3
                columnSpacing: 10
                rowSpacing: 10

                SettingsButton {
                    shell: page.shell
                    Layout.fillWidth: true
                    label: "Export selected"
                    enabled: !page.busy
                        && page.selectedSnapshotData !== null
                        && page.selectedSnapshotData.valid
                    onClicked: page.runAction([
                        "snapshot-export",
                        page.selectedSnapshot
                    ], false)
                }

                SettingsButton {
                    shell: page.shell
                    Layout.fillWidth: true
                    label: page.armedAction === "restore"
                        ? "Confirm restore"
                        : "Restore selected"
                    accent: shell.warning
                    filled: page.armedAction === "restore"
                    enabled: !page.busy
                        && page.selectedSnapshotData !== null
                        && page.selectedSnapshotData.valid
                    onClicked: page.confirmAction(
                        "restore",
                        page.selectedSnapshot,
                        ["snapshot-restore", page.selectedSnapshot]
                    )
                }

                SettingsButton {
                    shell: page.shell
                    Layout.fillWidth: true
                    label: page.armedAction === "delete"
                        ? "Confirm delete"
                        : "Delete selected"
                    danger: true
                    filled: page.armedAction === "delete"
                    enabled: !page.busy
                        && page.selectedSnapshotData !== null
                    onClicked: page.confirmAction(
                        "delete",
                        page.selectedSnapshot,
                        ["snapshot-delete", page.selectedSnapshot]
                    )
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                SettingsTextField {
                    shell: page.shell
                    Layout.fillWidth: true
                    prefix: "⇩"
                    placeholder: "Snapshot archive path"
                    text: page.importPath
                    onTextChanged: page.importPath = text
                    onAccepted: {
                        if (page.importPath.trim().length > 0) {
                            page.runAction([
                                "snapshot-import",
                                page.importPath.trim()
                            ], true)
                        }
                    }
                }

                SettingsButton {
                    shell: page.shell
                    Layout.preferredWidth: 118
                    label: "Import"
                    enabled: !page.busy
                        && page.importPath.trim().length > 0
                    onClicked: page.runAction([
                        "snapshot-import",
                        page.importPath.trim()
                    ], true)
                }
            }
        }

        SettingsCard {
            shell: page.shell
            Layout.fillWidth: true
            title: "Runtime operations"
            accent: shell.uiPalette[6]

            GridLayout {
                Layout.fillWidth: true
                columns: 4
                columnSpacing: 10
                rowSpacing: 10

                SettingsButton {
                    shell: page.shell
                    Layout.fillWidth: true
                    label: "Restart CHROMA"
                    accent: shell.uiPalette[4]
                    filled: true
                    enabled: !page.busy
                    onClicked: page.runAction(["restart-shell"], false)
                }

                SettingsButton {
                    shell: page.shell
                    Layout.fillWidth: true
                    label: "Reload Hyprland"
                    enabled: !page.busy
                    onClicked: page.runAction(["reload-hyprland"], true)
                }

                SettingsButton {
                    shell: page.shell
                    Layout.fillWidth: true
                    label: "Open log"
                    enabled: !page.busy
                    onClicked: page.runAction([
                        "config-open",
                        "log"
                    ], false)
                }

                SettingsButton {
                    shell: page.shell
                    Layout.fillWidth: true
                    label: "Open backups"
                    enabled: !page.busy
                    onClicked: page.runAction(["open-backups"], false)
                }
            }
        }

        SettingsCard {
            shell: page.shell
            Layout.fillWidth: true
            title: "Command output"
            accent: shell.uiPalette[0]

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 176
                color: shell.backgroundAlt
                border.width: shell.borderWidth
                border.color: shell.border
                radius: shell.cardRadius

                Text {
                    anchors {
                        fill: parent
                        margins: 12
                    }
                    text: page.output
                    color: shell.text
                    wrapMode: Text.WrapAnywhere
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: Math.round(8 * shell.fontScale)
                    font.weight: Font.Bold
                }
            }
        }
    }
}

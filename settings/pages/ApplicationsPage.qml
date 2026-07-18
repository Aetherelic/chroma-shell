import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Widgets
import "../components"

Flickable {
    id: page

    required property var shell
    required property var settings

    property string query: ""
    property string pickerQuery: ""
    property string pickerRole: ""
    property string selectedAppId: ""
    property var backendState: ({ defaults: ({}), autostart: [] })
    property string statusMessage: "APPLICATION INDEX READY"
    property bool busy: false
    property string pendingKind: ""
    property string pendingRole: ""
    property string pendingEntryId: ""
    property bool pendingEnabled: false

    readonly property var selectedApp:
        selectedAppId.length > 0
            ? DesktopEntries.byId(selectedAppId)
            : null

    property var filteredApps: {
        var entries = DesktopEntries.applications.values
        var needle = query.trim().toLowerCase()
        var result = []

        for (var index = 0; index < entries.length; index++) {
            var entry = entries[index]
            if (!entry || entry.noDisplay) {
                continue
            }

            var haystack = (
                (entry.name || "") + " "
                + (entry.genericName || "") + " "
                + (entry.comment || "") + " "
                + (entry.id || "") + " "
                + (entry.keywords || []).toString()
            ).toLowerCase()

            if (needle.length === 0 || haystack.indexOf(needle) >= 0) {
                result.push(entry)
            }
        }

        result.sort(function(left, right) {
            return (left.name || "").localeCompare(right.name || "")
        })

        return result.slice(0, 18)
    }

    property var pickerApps: {
        var entries = DesktopEntries.applications.values
        var needle = pickerQuery.trim().toLowerCase()
        var result = []

        for (var index = 0; index < entries.length; index++) {
            var entry = entries[index]
            if (!entry || entry.noDisplay) {
                continue
            }

            var haystack = (
                (entry.name || "") + " "
                + (entry.genericName || "") + " "
                + (entry.comment || "") + " "
                + (entry.id || "")
            ).toLowerCase()

            if (needle.length === 0 || haystack.indexOf(needle) >= 0) {
                result.push(entry)
            }
        }

        result.sort(function(left, right) {
            return (left.name || "").localeCompare(right.name || "")
        })

        return result.slice(0, 12)
    }

    contentWidth: width
    contentHeight: content.implicitHeight + 28
    clip: true

    function entryForId(id) {
        var value = String(id || "")
        return value.length > 0 ? DesktopEntries.byId(value) : null
    }

    function findEntryByHint(hint) {
        var needle = String(hint || "").trim().toLowerCase()
        if (needle.length === 0) {
            return null
        }

        var entries = DesktopEntries.applications.values
        for (var index = 0; index < entries.length; index++) {
            var entry = entries[index]
            if (!entry) {
                continue
            }

            var id = String(entry.id || "").toLowerCase()
            var name = String(entry.name || "").toLowerCase()
            var exec = String(entry.execString || "").toLowerCase()

            if (id === needle
                    || id.indexOf(needle) >= 0
                    || name === needle
                    || exec.indexOf(needle) >= 0) {
                return entry
            }
        }

        return null
    }

    function roleId(role) {
        var defaults = backendState.defaults || ({})
        switch (String(role)) {
        case "terminal":
            return settings.preferredTerminalId || ""
        case "browser":
            return settings.preferredBrowserId || defaults.browser || ""
        case "files":
            return settings.preferredFilesId || defaults.files || ""
        case "editor":
            return settings.preferredEditorId || defaults.editor || ""
        default:
            return ""
        }
    }

    function roleHint(role) {
        switch (String(role)) {
        case "terminal": return settings.preferredTerminal
        case "browser": return settings.preferredBrowser
        case "files": return settings.preferredFiles
        case "editor": return settings.preferredEditor
        default: return ""
        }
    }

    function roleEntry(role) {
        return entryForId(roleId(role)) || findEntryByHint(roleHint(role))
    }

    function applyLocalDefault(role, entry) {
        var command = String(entry.execString || entry.id || "")

        switch (String(role)) {
        case "terminal":
            settings.preferredTerminalId = entry.id
            settings.preferredTerminal = command
            break
        case "browser":
            settings.preferredBrowserId = entry.id
            settings.preferredBrowser = command
            break
        case "files":
            settings.preferredFilesId = entry.id
            settings.preferredFiles = command
            break
        case "editor":
            settings.preferredEditorId = entry.id
            settings.preferredEditor = command
            break
        }

        settings.scheduleSave()
    }

    function chooseDefault(entry) {
        if (!entry || pickerRole.length === 0 || busy) {
            return
        }

        pendingKind = "default"
        pendingRole = pickerRole
        pendingEntryId = entry.id
        runBackend([
            "application-set-default",
            pickerRole,
            entry.id
        ])
    }

    function isFavorite(id) {
        return settings.favoriteApplications.indexOf(String(id || "")) >= 0
    }

    function toggleFavorite(id) {
        var entryId = String(id || "")
        if (entryId.length === 0) {
            return
        }

        var next = settings.favoriteApplications.slice(0)
        var index = next.indexOf(entryId)
        if (index >= 0) {
            next.splice(index, 1)
        } else if (next.length < 12) {
            next.push(entryId)
        }

        settings.favoriteApplications = next
        settings.scheduleSave()
    }

    function moveFavorite(id, delta) {
        var next = settings.favoriteApplications.slice(0)
        var index = next.indexOf(String(id || ""))
        var target = index + Number(delta)

        if (index < 0 || target < 0 || target >= next.length) {
            return
        }

        var temporary = next[index]
        next[index] = next[target]
        next[target] = temporary
        settings.favoriteApplications = next
        settings.scheduleSave()
    }

    function isHidden(id) {
        return settings.hiddenApplications.indexOf(String(id || "")) >= 0
    }

    function toggleHidden(id) {
        var entryId = String(id || "")
        if (entryId.length === 0) {
            return
        }

        var next = settings.hiddenApplications.slice(0)
        var index = next.indexOf(entryId)
        if (index >= 0) {
            next.splice(index, 1)
        } else {
            next.push(entryId)
            var favorites = settings.favoriteApplications.slice(0)
            var favoriteIndex = favorites.indexOf(entryId)
            if (favoriteIndex >= 0) {
                favorites.splice(favoriteIndex, 1)
                settings.favoriteApplications = favorites
            }
        }

        settings.hiddenApplications = next
        settings.scheduleSave()
    }

    function isAutostartEnabled(id) {
        var entries = backendState.autostart || []
        return entries.indexOf(String(id || "")) >= 0
    }

    function toggleAutostart(id) {
        var entryId = String(id || "")
        if (entryId.length === 0 || busy) {
            return
        }

        pendingKind = "autostart"
        pendingEntryId = entryId
        pendingEnabled = !isAutostartEnabled(entryId)
        runBackend([
            "application-autostart-set",
            entryId,
            pendingEnabled ? "1" : "0"
        ])
    }

    function runBackend(arguments) {
        busy = true
        statusMessage = "APPLYING APPLICATION CONFIGURATION"
        var command = [
            "bash",
            Quickshell.shellPath("backend/chroma-settingsctl")
        ]

        for (var index = 0; index < arguments.length; index++) {
            command.push(String(arguments[index]))
        }

        actionProcess.exec(command)
    }

    function refreshBackend() {
        if (statusProcess.running) {
            return
        }

        statusProcess.exec([
            "bash",
            Quickshell.shellPath("backend/chroma-settingsctl"),
            "applications-json"
        ])
    }

    ScriptModel {
        id: applicationModel
        values: page.filteredApps
    }

    ScriptModel {
        id: pickerModel
        values: page.pickerApps
    }

    Process {
        id: statusProcess

        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    var result = JSON.parse(text)
                    if (result.ok === false) {
                        page.statusMessage = result.message || "APPLICATION STATUS FAILED"
                        return
                    }

                    page.backendState = result
                    page.statusMessage = "APPLICATION DEFAULTS AND AUTOSTART INDEXED"

                    var defaults = result.defaults || ({})
                    if (page.settings.preferredBrowserId.length === 0
                            && String(defaults.browser || "").length > 0) {
                        page.settings.preferredBrowserId = defaults.browser
                    }
                    if (page.settings.preferredFilesId.length === 0
                            && String(defaults.files || "").length > 0) {
                        page.settings.preferredFilesId = defaults.files
                    }
                    if (page.settings.preferredEditorId.length === 0
                            && String(defaults.editor || "").length > 0) {
                        page.settings.preferredEditorId = defaults.editor
                    }
                    page.settings.scheduleSave()
                } catch (error) {
                    page.statusMessage = "APPLICATION STATUS COULD NOT BE PARSED"
                }
            }
        }

        stderr: StdioCollector {
            onStreamFinished: {
                if (text.trim().length > 0) {
                    page.statusMessage = text.trim()
                }
            }
        }
    }

    Process {
        id: actionProcess

        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    var result = JSON.parse(text)
                    page.statusMessage = result.message || "APPLICATION CONFIGURATION UPDATED"

                    if (result.ok && page.pendingKind === "default") {
                        var entry = page.entryForId(page.pendingEntryId)
                        if (entry) {
                            page.applyLocalDefault(page.pendingRole, entry)
                        }
                        page.pickerRole = ""
                        page.pickerQuery = ""
                    }
                } catch (error) {
                    page.statusMessage = text.trim().length > 0
                        ? text.trim()
                        : "APPLICATION ACTION FAILED"
                }

                page.pendingKind = ""
                page.pendingRole = ""
                page.pendingEntryId = ""
                page.busy = false
                page.refreshBackend()
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

    Component.onCompleted: refreshBackend()

    ColumnLayout {
        id: content
        width: page.width
        spacing: 16

        PageHeader {
            shell: page.shell
            index: "05"
            title: "Applications"
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 38
            color: shell.backgroundAlt
            border.width: shell.borderWidth
            border.color: shell.border
            radius: shell.controlRadius

            RowLayout {
                anchors {
                    fill: parent
                    leftMargin: 12
                    rightMargin: 8
                }
                spacing: 10

                Rectangle {
                    Layout.preferredWidth: 7
                    Layout.preferredHeight: 7
                    radius: 99
                    color: page.busy ? shell.warning : shell.success
                }

                Text {
                    Layout.fillWidth: true
                    text: page.statusMessage
                    color: shell.muted
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: Math.round(8 * shell.fontScale)
                    font.weight: Font.Black
                    font.letterSpacing: 0.8
                    elide: Text.ElideRight
                }

                SettingsButton {
                    shell: page.shell
                    implicitWidth: 92
                    implicitHeight: 28
                    label: "Refresh"
                    enabled: !page.busy
                    onClicked: page.refreshBackend()
                }
            }
        }

        SettingsCard {
            shell: page.shell
            Layout.fillWidth: true
            title: "Preferred applications"
            accent: shell.uiPalette[1]

            GridLayout {
                Layout.fillWidth: true
                columns: 2
                rowSpacing: 10
                columnSpacing: 10

                Repeater {
                    model: [
                        { role: "terminal", label: "Terminal", glyph: "󰆍" },
                        { role: "browser", label: "Browser", glyph: "󰖟" },
                        { role: "files", label: "File manager", glyph: "󰉋" },
                        { role: "editor", label: "Text editor", glyph: "󰷈" }
                    ]

                    Rectangle {
                        id: roleCard
                        required property var modelData

                        property var application: page.roleEntry(modelData.role)

                        Layout.fillWidth: true
                        Layout.preferredHeight: 72
                        color: shell.backgroundAlt
                        border.width: shell.borderWidth
                        border.color: page.pickerRole === modelData.role
                            ? shell.uiPalette[1]
                            : shell.border
                        radius: shell.cardRadius

                        RowLayout {
                            anchors {
                                fill: parent
                                leftMargin: 12
                                rightMargin: 10
                            }
                            spacing: 11

                            Rectangle {
                                Layout.preferredWidth: 42
                                Layout.preferredHeight: 42
                                color: shell.surface
                                radius: shell.controlRadius

                                IconImage {
                                    anchors.centerIn: parent
                                    implicitSize: 28
                                    visible: roleCard.application !== null
                                    source: roleCard.application
                                        ? Quickshell.iconPath(
                                            roleCard.application.icon,
                                            "application-x-executable"
                                        )
                                        : ""
                                }

                                Text {
                                    anchors.centerIn: parent
                                    visible: roleCard.application === null
                                    text: roleCard.modelData.glyph
                                    color: shell.uiPalette[1]
                                    font.pixelSize: Math.round(19 * shell.fontScale)
                                }
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 2

                                Text {
                                    Layout.fillWidth: true
                                    text: roleCard.modelData.label.toUpperCase()
                                    color: shell.muted
                                    font.family: "JetBrainsMono Nerd Font"
                                    font.pixelSize: Math.round(7 * shell.fontScale)
                                    font.weight: Font.Black
                                    font.letterSpacing: 1
                                }

                                Text {
                                    Layout.fillWidth: true
                                    text: roleCard.application
                                        ? roleCard.application.name
                                        : "Not selected"
                                    color: shell.textStrong
                                    font.family: "JetBrainsMono Nerd Font"
                                    font.pixelSize: Math.round(10 * shell.fontScale)
                                    font.weight: Font.Black
                                    elide: Text.ElideRight
                                }
                            }

                            SettingsButton {
                                shell: page.shell
                                implicitWidth: 84
                                implicitHeight: 32
                                label: "Change"
                                enabled: !page.busy
                                filled: page.pickerRole === roleCard.modelData.role
                                accent: shell.uiPalette[1]
                                onClicked: {
                                    page.pickerRole = roleCard.modelData.role
                                    page.pickerQuery = ""
                                }
                            }
                        }
                    }
                }
            }
        }

        SettingsCard {
            shell: page.shell
            Layout.fillWidth: true
            visible: page.pickerRole.length > 0
            title: "Select " + page.pickerRole
            accent: shell.uiPalette[1]

            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                SettingsTextField {
                    shell: page.shell
                    Layout.fillWidth: true
                    prefix: "⌕"
                    placeholder: "Filter applications"
                    text: page.pickerQuery
                    onTextChanged: page.pickerQuery = text
                }

                SettingsButton {
                    shell: page.shell
                    implicitWidth: 90
                    label: "Cancel"
                    onClicked: {
                        page.pickerRole = ""
                        page.pickerQuery = ""
                    }
                }
            }

            GridLayout {
                Layout.fillWidth: true
                columns: 3
                rowSpacing: 8
                columnSpacing: 8

                Repeater {
                    model: pickerModel

                    Rectangle {
                        id: pickerRow
                        required property var modelData

                        Layout.fillWidth: true
                        Layout.preferredHeight: 58
                        color: pickerMouse.containsMouse
                            ? shell.surfaceHover
                            : shell.backgroundAlt
                        border.width: shell.borderWidth
                        border.color: pickerMouse.containsMouse
                            ? shell.uiPalette[1]
                            : shell.border
                        radius: shell.cardRadius

                        RowLayout {
                            anchors {
                                fill: parent
                                leftMargin: 10
                                rightMargin: 10
                            }
                            spacing: 9

                            IconImage {
                                Layout.preferredWidth: 28
                                Layout.preferredHeight: 28
                                source: Quickshell.iconPath(
                                    pickerRow.modelData.icon,
                                    "application-x-executable"
                                )
                            }

                            Text {
                                Layout.fillWidth: true
                                text: pickerRow.modelData.name || pickerRow.modelData.id
                                color: shell.text
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: Math.round(9 * shell.fontScale)
                                font.weight: Font.Black
                                elide: Text.ElideRight
                            }
                        }

                        MouseArea {
                            id: pickerMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: page.chooseDefault(pickerRow.modelData)
                        }
                    }
                }
            }
        }

        SettingsCard {
            shell: page.shell
            Layout.fillWidth: true
            title: "Launcher favourites"
            accent: shell.uiPalette[2]

            Text {
                visible: settings.favoriteApplications.length === 0
                Layout.fillWidth: true
                text: "NO FAVOURITES YET — SELECT AN APPLICATION BELOW"
                color: shell.dim
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: Math.round(8 * shell.fontScale)
                font.weight: Font.Black
                horizontalAlignment: Text.AlignHCenter
            }

            GridLayout {
                visible: settings.favoriteApplications.length > 0
                Layout.fillWidth: true
                columns: 3
                rowSpacing: 8
                columnSpacing: 8

                Repeater {
                    model: settings.favoriteApplications

                    Rectangle {
                        id: favoriteCard
                        required property string modelData
                        required property int index

                        property var application: page.entryForId(modelData)

                        Layout.fillWidth: true
                        Layout.preferredHeight: 66
                        color: shell.backgroundAlt
                        border.width: shell.borderWidth
                        border.color: shell.border
                        radius: shell.cardRadius

                        RowLayout {
                            anchors {
                                fill: parent
                                leftMargin: 10
                                rightMargin: 8
                            }
                            spacing: 8

                            IconImage {
                                Layout.preferredWidth: 30
                                Layout.preferredHeight: 30
                                source: favoriteCard.application
                                    ? Quickshell.iconPath(
                                        favoriteCard.application.icon,
                                        "application-x-executable"
                                    )
                                    : Quickshell.iconPath(
                                        "application-x-executable",
                                        "application-x-executable"
                                    )
                            }

                            Text {
                                Layout.fillWidth: true
                                text: favoriteCard.application
                                    ? favoriteCard.application.name
                                    : favoriteCard.modelData
                                color: shell.text
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: Math.round(9 * shell.fontScale)
                                font.weight: Font.Black
                                elide: Text.ElideRight
                            }

                            ColumnLayout {
                                spacing: 3

                                RowLayout {
                                    spacing: 3

                                    Rectangle {
                                        Layout.preferredWidth: 25
                                        Layout.preferredHeight: 22
                                        color: leftMouse.containsMouse
                                            ? shell.uiPalette[2]
                                            : shell.surface
                                        radius: shell.controlRadius
                                        opacity: favoriteCard.index > 0 ? 1 : 0.35

                                        Text {
                                            anchors.centerIn: parent
                                            text: "←"
                                            color: leftMouse.containsMouse
                                                ? shell.ink
                                                : shell.text
                                            font.weight: Font.Black
                                        }

                                        MouseArea {
                                            id: leftMouse
                                            anchors.fill: parent
                                            enabled: favoriteCard.index > 0
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: page.moveFavorite(favoriteCard.modelData, -1)
                                        }
                                    }

                                    Rectangle {
                                        Layout.preferredWidth: 25
                                        Layout.preferredHeight: 22
                                        color: rightMouse.containsMouse
                                            ? shell.uiPalette[2]
                                            : shell.surface
                                        radius: shell.controlRadius
                                        opacity: favoriteCard.index
                                            < settings.favoriteApplications.length - 1
                                                ? 1
                                                : 0.35

                                        Text {
                                            anchors.centerIn: parent
                                            text: "→"
                                            color: rightMouse.containsMouse
                                                ? shell.ink
                                                : shell.text
                                            font.weight: Font.Black
                                        }

                                        MouseArea {
                                            id: rightMouse
                                            anchors.fill: parent
                                            enabled: favoriteCard.index
                                                < settings.favoriteApplications.length - 1
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: page.moveFavorite(favoriteCard.modelData, 1)
                                        }
                                    }
                                }

                                Rectangle {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 22
                                    color: removeMouse.containsMouse
                                        ? shell.error
                                        : shell.surface
                                    radius: shell.controlRadius

                                    Text {
                                        anchors.centerIn: parent
                                        text: "REMOVE"
                                        color: removeMouse.containsMouse
                                            ? shell.ink
                                            : shell.muted
                                        font.family: "JetBrainsMono Nerd Font"
                                        font.pixelSize: Math.round(6 * shell.fontScale)
                                        font.weight: Font.Black
                                    }

                                    MouseArea {
                                        id: removeMouse
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: page.toggleFavorite(favoriteCard.modelData)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        SettingsCard {
            shell: page.shell
            Layout.fillWidth: true
            title: "Installed application index"
            accent: shell.uiPalette[4]

            SettingsTextField {
                shell: page.shell
                Layout.fillWidth: true
                prefix: "⌕"
                placeholder: "Filter applications"
                text: page.query
                onTextChanged: page.query = text
            }

            GridLayout {
                Layout.fillWidth: true
                columns: 3
                rowSpacing: 8
                columnSpacing: 8

                Repeater {
                    model: applicationModel

                    Rectangle {
                        id: appRow
                        required property var modelData

                        Layout.fillWidth: true
                        Layout.preferredHeight: 62
                        color: page.selectedAppId === modelData.id
                            ? shell.surfaceHover
                            : appMouse.containsMouse
                                ? shell.surfaceAlt
                                : shell.backgroundAlt
                        border.width: shell.borderWidth
                        border.color: page.selectedAppId === modelData.id
                            ? shell.uiPalette[4]
                            : shell.border
                        radius: shell.cardRadius

                        RowLayout {
                            anchors {
                                fill: parent
                                leftMargin: 10
                                rightMargin: 10
                            }
                            spacing: 10

                            IconImage {
                                Layout.preferredWidth: 30
                                Layout.preferredHeight: 30
                                source: Quickshell.iconPath(
                                    appRow.modelData.icon,
                                    "application-x-executable"
                                )
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 2

                                Text {
                                    Layout.fillWidth: true
                                    text: appRow.modelData.name || "APPLICATION"
                                    color: shell.text
                                    font.family: "JetBrainsMono Nerd Font"
                                    font.pixelSize: Math.round(9 * shell.fontScale)
                                    font.weight: Font.Black
                                    elide: Text.ElideRight
                                }

                                Text {
                                    Layout.fillWidth: true
                                    text: [
                                        page.isFavorite(appRow.modelData.id)
                                            ? "FAVOURITE"
                                            : "",
                                        page.isAutostartEnabled(appRow.modelData.id)
                                            ? "AUTOSTART"
                                            : "",
                                        page.isHidden(appRow.modelData.id)
                                            ? "HIDDEN"
                                            : ""
                                    ].filter(function(value) {
                                        return value.length > 0
                                    }).join("  ·  ") || appRow.modelData.id
                                    color: shell.muted
                                    font.family: "JetBrainsMono Nerd Font"
                                    font.pixelSize: Math.round(6 * shell.fontScale)
                                    font.weight: Font.Bold
                                    elide: Text.ElideRight
                                }
                            }
                        }

                        MouseArea {
                            id: appMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: page.selectedAppId = appRow.modelData.id
                            onDoubleClicked: appRow.modelData.execute()
                        }
                    }
                }
            }
        }

        SettingsCard {
            shell: page.shell
            Layout.fillWidth: true
            visible: page.selectedApp !== null
            title: "Selected application"
            accent: shell.uiPalette[4]

            RowLayout {
                Layout.fillWidth: true
                spacing: 14

                Rectangle {
                    Layout.preferredWidth: 54
                    Layout.preferredHeight: 54
                    color: shell.backgroundAlt
                    radius: shell.controlRadius

                    IconImage {
                        anchors.centerIn: parent
                        implicitSize: 38
                        source: page.selectedApp
                            ? Quickshell.iconPath(
                                page.selectedApp.icon,
                                "application-x-executable"
                            )
                            : ""
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2

                    Text {
                        Layout.fillWidth: true
                        text: page.selectedApp ? page.selectedApp.name : ""
                        color: shell.textStrong
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: Math.round(13 * shell.fontScale)
                        font.weight: Font.Black
                        elide: Text.ElideRight
                    }

                    Text {
                        Layout.fillWidth: true
                        text: page.selectedApp ? page.selectedApp.id : ""
                        color: shell.muted
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: Math.round(7 * shell.fontScale)
                        font.weight: Font.Bold
                        elide: Text.ElideRight
                    }
                }
            }

            GridLayout {
                Layout.fillWidth: true
                columns: 5
                rowSpacing: 8
                columnSpacing: 8

                SettingsButton {
                    shell: page.shell
                    Layout.fillWidth: true
                    label: "Launch"
                    filled: true
                    accent: shell.uiPalette[4]
                    onClicked: page.selectedApp.execute()
                }

                SettingsButton {
                    shell: page.shell
                    Layout.fillWidth: true
                    label: page.isFavorite(page.selectedAppId)
                        ? "Unfavourite"
                        : "Favourite"
                    onClicked: page.toggleFavorite(page.selectedAppId)
                }

                SettingsButton {
                    shell: page.shell
                    Layout.fillWidth: true
                    label: page.isHidden(page.selectedAppId)
                        ? "Show in launcher"
                        : "Hide in launcher"
                    onClicked: page.toggleHidden(page.selectedAppId)
                }

                SettingsButton {
                    shell: page.shell
                    Layout.fillWidth: true
                    label: page.isAutostartEnabled(page.selectedAppId)
                        ? "Disable autostart"
                        : "Enable autostart"
                    enabled: !page.busy
                    onClicked: page.toggleAutostart(page.selectedAppId)
                }

                SettingsButton {
                    shell: page.shell
                    Layout.fillWidth: true
                    label: "Open entry"
                    enabled: !page.busy
                    onClicked: {
                        page.pendingKind = "open"
                        page.pendingEntryId = page.selectedAppId
                        page.runBackend([
                            "application-open-entry",
                            page.selectedAppId
                        ])
                    }
                }
            }

            GridLayout {
                Layout.fillWidth: true
                columns: 4
                rowSpacing: 8
                columnSpacing: 8

                Repeater {
                    model: [
                        { role: "terminal", label: "Set terminal" },
                        { role: "browser", label: "Set browser" },
                        { role: "files", label: "Set files" },
                        { role: "editor", label: "Set editor" }
                    ]

                    SettingsButton {
                        required property var modelData

                        shell: page.shell
                        Layout.fillWidth: true
                        label: modelData.label
                        enabled: !page.busy
                        filled: page.roleId(modelData.role) === page.selectedAppId
                        accent: shell.uiPalette[1]
                        onClicked: {
                            page.pickerRole = modelData.role
                            page.chooseDefault(page.selectedApp)
                        }
                    }
                }
            }
        }

        SettingsCard {
            shell: page.shell
            Layout.fillWidth: true
            title: "Autostart"
            accent: shell.uiPalette[3]

            Text {
                visible: (page.backendState.autostart || []).length === 0
                Layout.fillWidth: true
                text: "NO ENABLED USER AUTOSTART ENTRIES"
                color: shell.dim
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: Math.round(8 * shell.fontScale)
                font.weight: Font.Black
                horizontalAlignment: Text.AlignHCenter
            }

            GridLayout {
                visible: (page.backendState.autostart || []).length > 0
                Layout.fillWidth: true
                columns: 2
                rowSpacing: 8
                columnSpacing: 8

                Repeater {
                    model: page.backendState.autostart || []

                    Rectangle {
                        id: autostartRow
                        required property string modelData

                        property var application: page.entryForId(modelData)

                        Layout.fillWidth: true
                        Layout.preferredHeight: 50
                        color: shell.backgroundAlt
                        border.width: shell.borderWidth
                        border.color: shell.border
                        radius: shell.cardRadius

                        RowLayout {
                            anchors {
                                fill: parent
                                leftMargin: 10
                                rightMargin: 8
                            }
                            spacing: 9

                            IconImage {
                                Layout.preferredWidth: 27
                                Layout.preferredHeight: 27
                                source: autostartRow.application
                                    ? Quickshell.iconPath(
                                        autostartRow.application.icon,
                                        "application-x-executable"
                                    )
                                    : Quickshell.iconPath(
                                        "application-x-executable",
                                        "application-x-executable"
                                    )
                            }

                            Text {
                                Layout.fillWidth: true
                                text: autostartRow.application
                                    ? autostartRow.application.name
                                    : autostartRow.modelData
                                color: shell.text
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: Math.round(9 * shell.fontScale)
                                font.weight: Font.Black
                                elide: Text.ElideRight
                            }

                            SettingsButton {
                                shell: page.shell
                                implicitWidth: 84
                                implicitHeight: 30
                                label: "Disable"
                                danger: true
                                enabled: !page.busy
                                onClicked: page.toggleAutostart(autostartRow.modelData)
                            }
                        }
                    }
                }
            }
        }
    }
}

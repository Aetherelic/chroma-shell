import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets

Scope {
    id: component

    required property var shell

    property string query: ""

    property var filteredEntries: {
        var needle = query.trim().toLowerCase()

        if (needle === "") {
            return []
        }

        var entries = DesktopEntries.applications.values
        var results = []

        for (var index = 0; index < entries.length; index++) {
            var entry = entries[index]

            if (!entry) {
                continue
            }

            var name = (entry.name || "").toLowerCase()
            var searchable = (
                (entry.name || "")
                + " "
                + (entry.genericName || "")
                + " "
                + (entry.comment || "")
                + " "
                + (entry.keywords || []).toString()
            ).toLowerCase()

            if (searchable.indexOf(needle) < 0) {
                continue
            }

            results.push(entry)
        }

        results.sort(function(left, right) {
            var leftName = (left.name || "").toLowerCase()
            var rightName = (right.name || "").toLowerCase()
            var leftExact = leftName === needle
            var rightExact = rightName === needle
            var leftStarts = leftName.indexOf(needle) === 0
            var rightStarts = rightName.indexOf(needle) === 0

            if (leftExact !== rightExact) {
                return leftExact ? -1 : 1
            }

            if (leftStarts !== rightStarts) {
                return leftStarts ? -1 : 1
            }

            return leftName.localeCompare(rightName)
        })

        return results.slice(0, shell.launcherResults)
    }

    function closeLauncher() {
        shell.launcherOpen = false
    }

    function launchEntry(entry) {
        if (!entry) {
            return
        }

        entry.execute()
        closeLauncher()
    }

    ScriptModel {
        id: appModel
        values: component.filteredEntries
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: launcherWindow

            required property var modelData

            property var selectedEntry:
                appList.currentItem
                    ? appList.currentItem.entry
                    : null

            function moveSelection(delta) {
                if (appList.count <= 0) {
                    return
                }

                var next = appList.currentIndex + delta

                if (next < 0) {
                    next = appList.count - 1
                } else if (next >= appList.count) {
                    next = 0
                }

                appList.currentIndex = next
                appList.positionViewAtIndex(next, ListView.Contain)
            }

            screen: modelData

            visible:
                modelData.name === shell.resolvedBarMonitor
                && shell.launcherOpen

            anchors {
                top: true
                bottom: true
                left: true
                right: true
            }

            exclusiveZone: 0
            aboveWindows: true
            focusable: shell.launcherOpen
            color: "transparent"

            WlrLayershell.namespace: "chroma-launcher"

            WlrLayershell.keyboardFocus:
                shell.launcherOpen
                    ? WlrKeyboardFocus.Exclusive
                    : WlrKeyboardFocus.None

            Timer {
                id: focusTimer
                interval: 40
                repeat: false

                onTriggered: {
                    searchInput.forceActiveFocus()
                    searchInput.selectAll()
                }
            }

            Connections {
                target: shell

                function onLauncherOpenChanged() {
                    if (shell.launcherOpen) {
                        searchInput.text = ""
                        component.query = ""
                        appList.currentIndex = -1
                        focusTimer.restart()
                    }
                }
            }

            Connections {
                target: component

                function onFilteredEntriesChanged() {
                    appList.currentIndex =
                        component.filteredEntries.length > 0
                            ? 0
                            : -1
                }
            }

            Rectangle {
                anchors.fill: parent
                color: "#33000000"

                MouseArea {
                    anchors.fill: parent
                    onClicked: component.closeLauncher()
                }
            }

            Rectangle {
                id: spotlight

                property int resultsHeight:
                    component.query.length === 0
                        ? 0
                        : (
                            component.filteredEntries.length > 0
                                ? component.filteredEntries.length * 56 + 28
                                : 64
                        )

                width: Math.min(760, launcherWindow.width - 80)
                height: 74 + resultsHeight

                anchors {
                    top: parent.top
                    horizontalCenter: parent.horizontalCenter
                    topMargin: 118
                }

                color: shell.backgroundAlt
                radius: shell.panelRadius
                border.width: shell.borderWidth
                border.color: searchInput.activeFocus
                    ? shell.uiPalette[4]
                    : shell.border
                clip: true

                Behavior on height {
                    NumberAnimation {
                        duration: 170
                        easing.type: Easing.OutCubic
                    }
                }

                Behavior on border.color {
                    ColorAnimation {
                        duration: 140
                    }
                }

                Rectangle {
                    anchors {
                        left: parent.left
                        top: parent.top
                        bottom: parent.bottom
                    }

                    width: 5
                    color: shell.uiPalette[
                        Math.floor(shell.tick / 18)
                        % shell.palette.length
                    ]

                    Behavior on color {
                        ColorAnimation {
                            duration: 420
                        }
                    }
                }

                ColumnLayout {
                    anchors {
                        fill: parent
                        leftMargin: 18
                        rightMargin: 14
                    }

                    spacing: 0

                    RowLayout {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 73
                        spacing: 14

                        Text {
                            text: "⌕"
                            color: shell.uiPalette[4]
                            font.pixelSize: Math.round(27 * shell.fontScale)
                            font.weight: Font.Black
                        }

                        Item {
                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            Text {
                                anchors {
                                    left: parent.left
                                    verticalCenter: parent.verticalCenter
                                }

                                visible: searchInput.text.length === 0
                                text: "Search applications…"
                                color: shell.dim
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: Math.round(16 * shell.fontScale)
                                font.weight: Font.Medium
                            }

                            TextInput {
                                id: searchInput

                                anchors.fill: parent
                                verticalAlignment: TextInput.AlignVCenter

                                color: shell.textStrong
                                selectionColor: shell.uiPalette[4]
                                selectedTextColor: shell.ink

                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: Math.round(16 * shell.fontScale)
                                font.weight: Font.Bold

                                clip: true

                                onTextChanged:
                                    component.query = text.trim().toLowerCase()

                                Keys.onPressed: event => {
                                    if (event.key === Qt.Key_Escape) {
                                        component.closeLauncher()
                                        event.accepted = true
                                    } else if (
                                        event.key === Qt.Key_Down
                                        || event.key === Qt.Key_Tab
                                    ) {
                                        launcherWindow.moveSelection(1)
                                        event.accepted = true
                                    } else if (
                                        event.key === Qt.Key_Up
                                        || event.key === Qt.Key_Backtab
                                    ) {
                                        launcherWindow.moveSelection(-1)
                                        event.accepted = true
                                    } else if (
                                        event.key === Qt.Key_Return
                                        || event.key === Qt.Key_Enter
                                    ) {
                                        component.launchEntry(
                                            launcherWindow.selectedEntry
                                        )
                                        event.accepted = true
                                    }
                                }
                            }
                        }

                        Rectangle {
                            width: 52
                            height: 28
                            radius: shell.controlRadius
                            color: shell.surface
                            border.width: shell.borderWidth
                            border.color: shell.border

                            Text {
                                anchors.centerIn: parent
                                text: "ESC"
                                color: shell.muted
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: Math.round(9 * shell.fontScale)
                                font.weight: Font.Black
                                font.letterSpacing: 1
                            }
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 1
                        visible: component.query.length > 0
                        color: shell.surfaceHover
                    }

                    ListView {
                        id: appList

                        Layout.fillWidth: true
                        Layout.preferredHeight:
                            component.filteredEntries.length * 56

                        visible:
                            component.query.length > 0
                            && component.filteredEntries.length > 0

                        model: appModel
                        currentIndex: -1
                        clip: true
                        boundsBehavior: Flickable.StopAtBounds
                        highlightMoveDuration: 120

                        delegate: Rectangle {
                            id: resultRow

                            required property var modelData
                            required property int index

                            property var entry: modelData
                            property bool selected:
                                ListView.isCurrentItem

                            width: ListView.view.width
                            height: 56
                            radius: shell.controlRadius

                            color: selected
                                ? shell.error
                                : (
                                    resultMouse.containsMouse
                                        ? shell.surfaceAlt
                                        : "transparent"
                                )

                            Behavior on color {
                                ColorAnimation {
                                    duration: 110
                                }
                            }

                            RowLayout {
                                anchors {
                                    fill: parent
                                    leftMargin: 10
                                    rightMargin: 12
                                }

                                spacing: 12

                                Rectangle {
                                    Layout.preferredWidth: 40
                                    Layout.preferredHeight: 40
                                    radius: shell.controlRadius
                                    color: resultRow.selected
                                        ? shell.ink
                                        : shell.surface

                                    IconImage {
                                        anchors.centerIn: parent
                                        implicitSize: 28
                                        asynchronous: true
                                        source: Quickshell.iconPath(
                                            resultRow.entry.icon,
                                            "application-x-executable"
                                        )
                                    }
                                }

                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 1

                                    Text {
                                        Layout.fillWidth: true
                                        text: resultRow.entry.name || "Application"
                                        color: resultRow.selected
                                            ? shell.ink
                                            : shell.text
                                        font.family: "JetBrainsMono Nerd Font"
                                        font.pixelSize: Math.round(13 * shell.fontScale)
                                        font.weight: Font.Black
                                        elide: Text.ElideRight
                                    }

                                    Text {
                                        Layout.fillWidth: true
                                        text: (
                                            resultRow.entry.genericName
                                            || resultRow.entry.comment
                                            || "Application"
                                        ).toUpperCase()
                                        color: resultRow.selected
                                            ? shell.surfaceHover
                                            : shell.muted
                                        font.family: "JetBrainsMono Nerd Font"
                                        font.pixelSize: Math.round(8 * shell.fontScale)
                                        font.weight: Font.Bold
                                        font.letterSpacing: 1
                                        elide: Text.ElideRight
                                    }
                                }

                                Text {
                                    text: resultRow.selected ? "↵" : ""
                                    color: shell.ink
                                    font.pixelSize: Math.round(18 * shell.fontScale)
                                    font.weight: Font.Black
                                }
                            }

                            MouseArea {
                                id: resultMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor

                                onEntered:
                                    appList.currentIndex = resultRow.index

                                onClicked:
                                    component.launchEntry(resultRow.entry)
                            }
                        }
                    }

                    Item {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 63
                        visible:
                            component.query.length > 0
                            && component.filteredEntries.length === 0

                        Text {
                            anchors.centerIn: parent
                            text: "No matching applications"
                            color: shell.muted
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: Math.round(11 * shell.fontScale)
                            font.weight: Font.Bold
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 27
                        visible:
                            component.query.length > 0
                            && component.filteredEntries.length > 0

                        Text {
                            text:
                                component.filteredEntries.length
                                + " RESULTS"
                            color: shell.dim
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: Math.round(8 * shell.fontScale)
                            font.weight: Font.Black
                            font.letterSpacing: 1.2
                        }

                        Item {
                            Layout.fillWidth: true
                        }

                        Text {
                            text: "↑↓ NAVIGATE   ↵ OPEN"
                            color: shell.dim
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: Math.round(8 * shell.fontScale)
                            font.weight: Font.Black
                            font.letterSpacing: 1
                        }
                    }
                }
            }
        }
    }
}

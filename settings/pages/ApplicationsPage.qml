import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import "../components"

Flickable {
    id: page

    required property var shell
    required property var settings

    property string query: ""
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
                + (entry.comment || "")
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

    ScriptModel {
        id: applicationModel
        values: page.filteredApps
    }

    ColumnLayout {
        id: content
        width: page.width
        spacing: 16

        PageHeader {
            shell: page.shell
            index: "05"
            title: "Applications"
            subtitle: "Preferred commands and the installed desktop-entry index"
        }

        SettingsCard {
            shell: page.shell
            Layout.fillWidth: true
            title: "Preferred applications"
            subtitle: "Commands are stored for CHROMA actions and future quick-launch integration"
            accent: shell.uiPalette[1]

            GridLayout {
                Layout.fillWidth: true
                columns: 2
                rowSpacing: 10
                columnSpacing: 10

                SettingsTextField {
                    shell: page.shell
                    Layout.fillWidth: true
                    prefix: "TERM"
                    placeholder: "Terminal command"
                    text: settings.preferredTerminal
                    onTextChanged: {
                        settings.preferredTerminal = text
                        settings.scheduleSave()
                    }
                }

                SettingsTextField {
                    shell: page.shell
                    Layout.fillWidth: true
                    prefix: "WEB"
                    placeholder: "Browser command"
                    text: settings.preferredBrowser
                    onTextChanged: {
                        settings.preferredBrowser = text
                        settings.scheduleSave()
                    }
                }

                SettingsTextField {
                    shell: page.shell
                    Layout.fillWidth: true
                    prefix: "FILE"
                    placeholder: "File manager command"
                    text: settings.preferredFiles
                    onTextChanged: {
                        settings.preferredFiles = text
                        settings.scheduleSave()
                    }
                }

                SettingsTextField {
                    shell: page.shell
                    Layout.fillWidth: true
                    prefix: "EDIT"
                    placeholder: "Editor command"
                    text: settings.preferredEditor
                    onTextChanged: {
                        settings.preferredEditor = text
                        settings.scheduleSave()
                    }
                }
            }
        }

        SettingsCard {
            shell: page.shell
            Layout.fillWidth: true
            title: "Installed application index"
            subtitle: "Search and launch visible desktop entries"
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
                columns: 2
                rowSpacing: 8
                columnSpacing: 8

                Repeater {
                    model: applicationModel

                    Rectangle {
                        id: appRow
                        required property var modelData

                        Layout.fillWidth: true
                        Layout.preferredHeight: 58
                        color: appMouse.containsMouse
                            ? shell.surfaceHover
                            : shell.backgroundAlt
                        border.width: shell.borderWidth
                        border.color: appMouse.containsMouse
                            ? shell.uiPalette[4]
                            : shell.border
                        radius: shell.cardRadius

                        RowLayout {
                            anchors {
                                fill: parent
                                leftMargin: 12
                                rightMargin: 12
                            }
                            spacing: 10

                            IconImage {
                                Layout.preferredWidth: 30
                                Layout.preferredHeight: 30
                                source: Quickshell.iconPath(
                                    appRow.modelData.icon || "application-x-executable",
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
                                    font.pixelSize: Math.round(10 * shell.fontScale)
                                    font.weight: Font.Black
                                    elide: Text.ElideRight
                                }

                                Text {
                                    Layout.fillWidth: true
                                    text: appRow.modelData.genericName
                                        || appRow.modelData.comment
                                        || appRow.modelData.id
                                    color: shell.muted
                                    font.family: "JetBrainsMono Nerd Font"
                                    font.pixelSize: Math.round(7 * shell.fontScale)
                                    font.weight: Font.Bold
                                    elide: Text.ElideRight
                                }
                            }

                            Text {
                                text: "↗"
                                color: appMouse.containsMouse
                                    ? shell.uiPalette[4]
                                    : shell.dim
                                font.pixelSize: Math.round(18 * shell.fontScale)
                                font.weight: Font.Black
                            }
                        }

                        MouseArea {
                            id: appMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: appRow.modelData.execute()
                        }
                    }
                }
            }
        }
    }
}

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland

Scope {
    id: component

    required property var shell
    required property var store

    Variants {
        model: store.widgets

        PanelWindow {
            id: widgetWindow
            required property var modelData

            readonly property var resolvedScreen: shell.screenFor(modelData.monitor)
            readonly property real availableWidth:
                resolvedScreen !== null
                    ? Math.max(1, resolvedScreen.width - modelData.width)
                    : 1
            readonly property real availableHeight:
                resolvedScreen !== null
                    ? Math.max(1, resolvedScreen.height - modelData.height)
                    : 1

            screen: resolvedScreen
            visible:
                store.ready
                && store.enabled
                && !store.editMode
                && resolvedScreen !== null
                && store.isMonitorEnabled(modelData.monitor)

            anchors { top: true; left: true }
            margins {
                left: Math.round(modelData.x * availableWidth)
                top: Math.round(modelData.y * availableHeight)
            }

            implicitWidth: modelData.width
            implicitHeight: modelData.height
            exclusiveZone: 0
            aboveWindows: false
            focusable: false
            color: "transparent"

            WlrLayershell.layer: WlrLayer.Bottom
            WlrLayershell.namespace: "chroma-widget-" + modelData.id

            WidgetFrame {
                anchors.fill: parent
                shell: component.shell
                widgetData: widgetWindow.modelData
                editMode: false
            }
        }
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: editWindow
            required property var modelData

            property var monitorWidgets: store.widgetsForMonitor(modelData.name)

            screen: modelData
            visible:
                store.ready
                && store.enabled
                && store.editMode
                && store.isMonitorEnabled(modelData.name)

            anchors { top: true; bottom: true; left: true; right: true }
            exclusiveZone: 0
            aboveWindows: true
            focusable: store.editMode
            color: "transparent"

            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.namespace: "chroma-widget-editor-" + modelData.name
            WlrLayershell.keyboardFocus:
                store.editMode
                    ? WlrKeyboardFocus.Exclusive
                    : WlrKeyboardFocus.None

            Rectangle {
                anchors.fill: parent
                color: "#66000000"

                MouseArea {
                    anchors.fill: parent
                    onClicked: store.selectedId = ""
                }
            }

            Canvas {
                id: gridCanvas
                anchors.fill: parent
                opacity: 0.36

                onPaint: {
                    var context = getContext("2d")
                    context.clearRect(0, 0, width, height)
                    var step = Math.max(8, store.snapSize)
                    context.strokeStyle = Qt.rgba(
                        shell.uiPalette[4].r,
                        shell.uiPalette[4].g,
                        shell.uiPalette[4].b,
                        0.17
                    )
                    context.lineWidth = 1
                    for (var x = step; x < width; x += step) {
                        context.beginPath()
                        context.moveTo(x + 0.5, 0)
                        context.lineTo(x + 0.5, height)
                        context.stroke()
                    }
                    for (var y = step; y < height; y += step) {
                        context.beginPath()
                        context.moveTo(0, y + 0.5)
                        context.lineTo(width, y + 0.5)
                        context.stroke()
                    }
                }

                Connections {
                    target: store
                    function onSnapSizeChanged() { gridCanvas.requestPaint() }
                }
            }

            Repeater {
                model: editWindow.monitorWidgets

                WidgetFrame {
                    id: editable
                    required property var modelData

                    property real resizeStartWidth: width
                    property real resizeStartHeight: height

                    x: Math.round(modelData.x * Math.max(1, editWindow.width - width))
                    y: Math.round(modelData.y * Math.max(1, editWindow.height - height))
                    width: modelData.width
                    height: modelData.height
                    z: selected ? 10 : 1

                    shell: component.shell
                    widgetData: modelData
                    editMode: true
                    selected: store.selectedId === modelData.id

                    TapHandler {
                        onTapped: store.selectedId = editable.modelData.id
                    }

                    DragHandler {
                        id: moveHandler
                        enabled: !editable.modelData.locked
                        target: editable

                        onActiveChanged: {
                            if (active) {
                                store.selectedId = editable.modelData.id
                            } else {
                                editable.x = Math.max(
                                    0,
                                    Math.min(editWindow.width - editable.width, editable.x)
                                )
                                editable.y = Math.max(
                                    0,
                                    Math.min(editWindow.height - editable.height, editable.y)
                                )
                                var snap = Math.max(1, store.snapSize)
                                editable.x = Math.round(editable.x / snap) * snap
                                editable.y = Math.round(editable.y / snap) * snap
                                store.updateGeometry(
                                    editable.modelData.id,
                                    editable.x / Math.max(1, editWindow.width - editable.width),
                                    editable.y / Math.max(1, editWindow.height - editable.height),
                                    editable.width,
                                    editable.height
                                )
                            }
                        }
                    }

                    Row {
                        visible: editable.selected
                        anchors {
                            top: parent.top
                            right: parent.right
                            margins: 8
                        }
                        spacing: 5
                        z: 30

                        Repeater {
                            model: [
                                { label: editable.modelData.locked ? "󰌾" : "󰌿", action: "LOCK" },
                                { label: "󰆏", action: "DUPLICATE" },
                                { label: "󰆴", action: "REMOVE" }
                            ]

                            Rectangle {
                                id: editAction
                                required property var modelData
                                width: 28
                                height: 28
                                color: editActionMouse.containsMouse
                                    ? (modelData.action === "REMOVE" ? shell.error : shell.uiPalette[4])
                                    : shell.backgroundAlt
                                border.width: shell.borderWidth
                                border.color: shell.border
                                radius: shell.controlRadius

                                Text {
                                    anchors.centerIn: parent
                                    text: editAction.modelData.label
                                    color: editActionMouse.containsMouse ? shell.ink : shell.text
                                    font.family: "JetBrainsMono Nerd Font"
                                    font.pixelSize: 13
                                }

                                MouseArea {
                                    id: editActionMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        if (editAction.modelData.action === "LOCK") {
                                            store.setLocked(
                                                editable.modelData.id,
                                                !editable.modelData.locked
                                            )
                                        } else if (editAction.modelData.action === "DUPLICATE") {
                                            store.duplicateWidget(editable.modelData.id)
                                        } else {
                                            store.removeWidget(editable.modelData.id)
                                        }
                                    }
                                }
                            }
                        }
                    }

                    Rectangle {
                        id: resizeHandle
                        visible: editable.selected && !editable.modelData.locked
                        anchors { right: parent.right; bottom: parent.bottom }
                        width: 30
                        height: 30
                        color: shell.uiPalette[6]
                        radius: shell.controlRadius
                        z: 30

                        Text {
                            anchors.centerIn: parent
                            text: "◢"
                            color: shell.ink
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 14
                            font.weight: Font.Black
                        }

                        DragHandler {
                            target: null

                            onActiveChanged: {
                                if (active) {
                                    editable.resizeStartWidth = editable.width
                                    editable.resizeStartHeight = editable.height
                                    store.selectedId = editable.modelData.id
                                } else {
                                    var snap = Math.max(1, store.snapSize)
                                    editable.width = Math.round(editable.width / snap) * snap
                                    editable.height = Math.round(editable.height / snap) * snap
                                    store.updateGeometry(
                                        editable.modelData.id,
                                        editable.x / Math.max(1, editWindow.width - editable.width),
                                        editable.y / Math.max(1, editWindow.height - editable.height),
                                        editable.width,
                                        editable.height
                                    )
                                }
                            }

                            onTranslationChanged: {
                                if (!active) return
                                editable.width = Math.max(
                                    220,
                                    Math.min(
                                        editWindow.width - editable.x,
                                        editable.resizeStartWidth + translation.x
                                    )
                                )
                                editable.height = Math.max(
                                    120,
                                    Math.min(
                                        editWindow.height - editable.y,
                                        editable.resizeStartHeight + translation.y
                                    )
                                )
                            }
                        }
                    }
                }
            }

            Rectangle {
                anchors {
                    top: parent.top
                    horizontalCenter: parent.horizontalCenter
                    topMargin: 22
                }
                width: Math.min(760, parent.width - 48)
                height: 56
                color: Qt.rgba(
                    shell.backgroundAlt.r,
                    shell.backgroundAlt.g,
                    shell.backgroundAlt.b,
                    0.96
                )
                border.width: shell.borderWidth
                border.color: shell.uiPalette[4]
                radius: shell.panelRadius
                z: 100

                RowLayout {
                    anchors {
                        fill: parent
                        leftMargin: 16
                        rightMargin: 16
                    }
                    spacing: 12

                    Text {
                        Layout.alignment: Qt.AlignVCenter
                        text: "CHROMA // EDIT MODE"
                        color: shell.textStrong
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: Math.round(9 * shell.fontScale)
                        font.weight: Font.Black
                        font.letterSpacing: 0.8
                    }

                    Rectangle {
                        Layout.alignment: Qt.AlignVCenter
                        width: 1
                        height: 22
                        color: shell.borderStrong
                    }

                    Text {
                        Layout.alignment: Qt.AlignVCenter
                        text: editWindow.modelData.name
                        color: shell.uiPalette[4]
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: Math.round(8 * shell.fontScale)
                        font.weight: Font.Black
                    }

                    Text {
                        Layout.alignment: Qt.AlignVCenter
                        text: "GRID " + store.snapSize + "PX"
                        color: shell.muted
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: Math.round(7 * shell.fontScale)
                        font.weight: Font.Bold
                    }

                    Item { Layout.fillWidth: true }

                    Text {
                        Layout.alignment: Qt.AlignVCenter
                        text: "DRAG  ·  RESIZE  ·  ESC"
                        color: shell.dim
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: Math.round(7 * shell.fontScale)
                        font.weight: Font.Bold
                    }
                }
            }

            Item {
                id: keyTarget
                anchors.fill: parent
                focus: store.editMode
                Keys.onEscapePressed: store.editMode = false
            }

            Connections {
                target: store
                function onEditModeChanged() {
                    if (store.editMode && editWindow.visible) {
                        keyTarget.forceActiveFocus()
                    }
                }
            }
        }
    }
}

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Notifications
import Quickshell.Widgets

Scope {
    id: component

    required property var shell

    readonly property int notificationCount:
        server.trackedNotifications.values.length

    property int activeToastCount: 0

    function accentFor(notification) {
        if (notification.urgency === NotificationUrgency.Critical) {
            return shell.uiPalette[0]
        }

        if (notification.urgency === NotificationUrgency.Low) {
            return shell.uiPalette[4]
        }

        return shell.uiPalette[6]
    }

    function iconFor(notification) {
        var source = notification.image || notification.appIcon || ""

        if (source === "") {
            return ""
        }

        if (
            source.indexOf("file:") === 0
            || source.indexOf("image:") === 0
            || source.indexOf("/") === 0
        ) {
            return source
        }

        return Quickshell.iconPath(source, true)
    }

    function clearAll() {
        var notifications =
            server.trackedNotifications.values.slice()

        for (var index = 0; index < notifications.length; index++) {
            notifications[index].dismiss()
        }
    }

    NotificationServer {
        id: server

        actionsSupported: true
        imageSupported: true
        persistenceSupported: true
        bodySupported: true
        bodyMarkupSupported: false
        keepOnReload: true

        onNotification: function(notification) {
            notification.tracked = true
        }
    }

    /*
     * TRANSIENT TOAST RAIL
     */
    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: toastWindow

            required property var modelData

            screen: modelData
            visible:
                modelData.name === shell.resolvedBarMonitor
                && component.activeToastCount > 0

            anchors {
                right: true
                top: shell.barPosition === "TOP"
                bottom: shell.barPosition !== "TOP"
            }

            margins {
                right: 18
                top: shell.barPosition === "TOP" ? shell.barHeight + 28 : 0
                bottom: shell.barPosition === "BOTTOM" ? shell.barHeight + 28 : 0
            }

            implicitWidth: 430
            implicitHeight: 650
            exclusiveZone: 0
            aboveWindows: true
            color: "transparent"
            mask: Region { item: toastColumn }

            Column {
                id: toastColumn

                anchors {
                    right: parent.right
                    top:
                        shell.barPosition === "TOP"
                            ? parent.top
                            : undefined
                    bottom:
                        shell.barPosition === "BOTTOM"
                            ? parent.bottom
                            : undefined
                }

                width: 420
                spacing: 8

                Repeater {
                    model: server.trackedNotifications

                    Rectangle {
                        id: toast

                        required property var modelData

                        property bool showing: false

                        width: 420
                        height: showing ? 112 : 0
                        visible: showing
                        opacity: showing ? 1 : 0

                        color: shell.backgroundAlt
                        radius: shell.panelRadius
                        border.width: shell.borderWidth
                        border.color:
                            component.accentFor(modelData)
                        clip: true

                        Behavior on height {
                            NumberAnimation {
                                duration: 180
                                easing.type: Easing.OutCubic
                            }
                        }

                        Behavior on opacity {
                            NumberAnimation {
                                duration: 140
                            }
                        }

                        function hideToast() {
                            if (!showing) {
                                return
                            }

                            showing = false
                            component.activeToastCount = Math.max(
                                0,
                                component.activeToastCount - 1
                            )

                            if (modelData.transient) {
                                modelData.expire()
                            }
                        }

                        Component.onCompleted: {
                            showing =
                                !modelData.lastGeneration
                                && shell.showNotificationToasts
                                && !shell.doNotDisturb
                                && !shell.notificationCenterOpen

                            if (showing) {
                                component.activeToastCount += 1
                                hideTimer.restart()
                            }
                        }

                        Component.onDestruction: {
                            if (showing) {
                                component.activeToastCount = Math.max(
                                    0,
                                    component.activeToastCount - 1
                                )
                            }
                        }

                        Timer {
                            id: hideTimer

                            interval:
                                toast.modelData.urgency
                                    === NotificationUrgency.Critical
                                    ? 10000
                                    : Math.max(
                                        3500,
                                        Math.min(
                                            20000,
                                            toast.modelData.expireTimeout > 0
                                                ? toast.modelData.expireTimeout * 1000
                                                : shell.notificationTimeout * 1000
                                        )
                                    )

                            repeat: false
                            onTriggered: toast.hideToast()
                        }

                        Rectangle {
                            anchors {
                                left: parent.left
                                top: parent.top
                                bottom: parent.bottom
                            }

                            width: 7
                            color: component.accentFor(toast.modelData)
                        }

                        RowLayout {
                            anchors {
                                fill: parent
                                leftMargin: 18
                                rightMargin: 12
                                topMargin: 12
                                bottomMargin: 12
                            }

                            spacing: 12

                            Rectangle {
                                Layout.preferredWidth: 54
                                Layout.preferredHeight: 54
                                color: shell.surface
                                radius: shell.controlRadius
                                clip: true

                                IconImage {
                                    id: toastIcon

                                    anchors.centerIn: parent
                                    implicitSize: 34
                                    source:
                                        component.iconFor(toast.modelData)
                                    asynchronous: true
                                    mipmap: true
                                }

                                Text {
                                    anchors.centerIn: parent
                                    visible:
                                        toastIcon.source === ""
                                        || toastIcon.status === Image.Error
                                    text: (toast.modelData.appName || "N")
                                        .charAt(0)
                                        .toUpperCase()
                                    color:
                                        component.accentFor(toast.modelData)
                                    font.family:
                                        "JetBrainsMono Nerd Font"
                                    font.pixelSize: Math.round(22 * shell.fontScale)
                                    font.weight: Font.Black
                                }
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                spacing: 3

                                RowLayout {
                                    Layout.fillWidth: true

                                    Text {
                                        Layout.fillWidth: true
                                        text:
                                            toast.modelData.appName
                                            || "SYSTEM EVENT"
                                        color:
                                            component.accentFor(
                                                toast.modelData
                                            )
                                        font.family:
                                            "JetBrainsMono Nerd Font"
                                        font.pixelSize: Math.round(8 * shell.fontScale)
                                        font.weight: Font.Black
                                        font.letterSpacing: 1.5
                                        elide: Text.ElideRight
                                    }

                                    Text {
                                        text:
                                            toast.modelData.urgency
                                                === NotificationUrgency.Critical
                                                ? "CRITICAL"
                                                : "LIVE"
                                        color: shell.muted
                                        font.family:
                                            "JetBrainsMono Nerd Font"
                                        font.pixelSize: Math.round(7 * shell.fontScale)
                                        font.weight: Font.Bold
                                        font.letterSpacing: 1
                                    }
                                }

                                Text {
                                    Layout.fillWidth: true
                                    text:
                                        toast.modelData.summary
                                        || "UNTITLED NOTIFICATION"
                                    color: shell.textStrong
                                    font.family:
                                        "JetBrainsMono Nerd Font"
                                    font.pixelSize: Math.round(12 * shell.fontScale)
                                    font.weight: Font.Black
                                    elide: Text.ElideRight
                                }

                                Text {
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    text: toast.modelData.body || ""
                                    textFormat: Text.PlainText
                                    color: shell.muted
                                    font.family:
                                        "JetBrainsMono Nerd Font"
                                    font.pixelSize: Math.round(9 * shell.fontScale)
                                    font.weight: Font.Medium
                                    wrapMode: Text.Wrap
                                    elide: Text.ElideRight
                                    maximumLineCount: 2
                                }
                            }

                            Rectangle {
                                Layout.preferredWidth: 32
                                Layout.preferredHeight: 32
                                Layout.alignment: Qt.AlignTop
                                color: closeToastMouse.containsMouse
                                    ? shell.uiPalette[0]
                                    : shell.surfaceAlt
                                radius: shell.controlRadius

                                Text {
                                    anchors.centerIn: parent
                                    text: "×"
                                    color: closeToastMouse.containsMouse
                                        ? shell.ink
                                        : shell.text
                                    font.pixelSize: Math.round(18 * shell.fontScale)
                                    font.weight: Font.Black
                                }

                                MouseArea {
                                    id: closeToastMouse

                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor

                                    onClicked: {
                                        toast.hideToast()
                                        toast.modelData.dismiss()
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    /*
     * NOTIFICATION HISTORY PANEL
     */
    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: historyWindow

            required property var modelData

            screen: modelData
            visible:
                modelData.name === shell.resolvedBarMonitor
                && shell.notificationCenterOpen

            anchors {
                left: true
                right: true
                top: true
                bottom: true
            }

            exclusiveZone: 0
            aboveWindows: true
            focusable: true
            color: "transparent"

            Rectangle {
                anchors.fill: parent
                color: "#26000000"

                MouseArea {
                    anchors.fill: parent
                    onClicked:
                        shell.notificationCenterOpen = false
                }
            }

            Rectangle {
                id: historyPanel

                width: 472
                height: Math.min(620, historyWindow.height - 130)

                anchors {
                    right: parent.right
                    top:
                        shell.barPosition === "TOP"
                            ? parent.top
                            : undefined
                    bottom:
                        shell.barPosition === "BOTTOM"
                            ? parent.bottom
                            : undefined
                    rightMargin: 18
                    topMargin:
                        shell.barPosition === "TOP"
                            ? shell.barHeight + 28
                            : 0
                    bottomMargin:
                        shell.barPosition === "BOTTOM"
                            ? shell.barHeight + 28
                            : 0
                }

                color: shell.background
                radius: shell.panelRadius
                border.width: shell.borderWidth
                border.color: shell.border
                clip: true

                MouseArea {
                    anchors.fill: parent
                }

                Row {
                    anchors {
                        top: parent.top
                        left: parent.left
                        right: parent.right
                    }

                    height: 5

                    Repeater {
                        model: 7

                        Rectangle {
                            required property int index
                            width: historyPanel.width / 7
                            height: 5
                            color: shell.uiPalette[index]
                        }
                    }
                }

                ColumnLayout {
                    anchors {
                        fill: parent
                        topMargin: 20
                        bottomMargin: 16
                        leftMargin: 18
                        rightMargin: 18
                    }

                    spacing: 12

                    RowLayout {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 48

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 2

                            Text {
                                text: "CHROMA//SIGNALS"
                                color: shell.textStrong
                                font.family:
                                    "JetBrainsMono Nerd Font"
                                font.pixelSize: Math.round(17 * shell.fontScale)
                                font.weight: Font.Black
                                font.letterSpacing: 1
                            }

                            Text {
                                text:
                                    component.notificationCount
                                    + " RETAINED EVENTS // LIVE"
                                color: shell.uiPalette[6]
                                font.family:
                                    "JetBrainsMono Nerd Font"
                                font.pixelSize: Math.round(8 * shell.fontScale)
                                font.weight: Font.Black
                                font.letterSpacing: 1.4
                            }
                        }

                        Rectangle {
                            width: 80
                            height: 38
                            radius: shell.controlRadius
                            color: shell.doNotDisturb
                                ? shell.uiPalette[2]
                                : dndMouse.containsMouse
                                    ? shell.uiPalette[4]
                                    : shell.surface
                            border.width:
                                shell.doNotDisturb
                                || dndMouse.containsMouse
                                    ? 0
                                    : 1
                            border.color: shell.borderStrong

                            Text {
                                anchors.centerIn: parent
                                text: shell.doNotDisturb
                                    ? "DND ON"
                                    : "DND OFF"
                                color:
                                    shell.doNotDisturb
                                    || dndMouse.containsMouse
                                        ? shell.ink
                                        : shell.text
                                font.family:
                                    "JetBrainsMono Nerd Font"
                                font.pixelSize: Math.round(8 * shell.fontScale)
                                font.weight: Font.Black
                                font.letterSpacing: 1
                            }

                            MouseArea {
                                id: dndMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked:
                                    shell.doNotDisturb =
                                        !shell.doNotDisturb
                            }
                        }

                        Rectangle {
                            width: 62
                            height: 38
                            radius: shell.controlRadius
                            color: clearMouse.containsMouse
                                ? shell.uiPalette[0]
                                : shell.surface
                            border.width: clearMouse.containsMouse ? 0 : shell.borderWidth
                            border.color: shell.borderStrong

                            Text {
                                anchors.centerIn: parent
                                text: "CLEAR"
                                color: clearMouse.containsMouse
                                    ? shell.ink
                                    : shell.text
                                font.family:
                                    "JetBrainsMono Nerd Font"
                                font.pixelSize: Math.round(8 * shell.fontScale)
                                font.weight: Font.Black
                                font.letterSpacing: 1
                            }

                            MouseArea {
                                id: clearMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: component.clearAll()
                            }
                        }

                        Rectangle {
                            width: 38
                            height: 38
                            radius: shell.controlRadius
                            color: closeHistoryMouse.containsMouse
                                ? shell.uiPalette[0]
                                : shell.surface
                            border.width:
                                closeHistoryMouse.containsMouse ? 0 : shell.borderWidth
                            border.color: shell.borderStrong

                            Text {
                                anchors.centerIn: parent
                                text: "×"
                                color: closeHistoryMouse.containsMouse
                                    ? shell.ink
                                    : shell.text
                                font.pixelSize: Math.round(22 * shell.fontScale)
                                font.weight: Font.Black
                            }

                            MouseArea {
                                id: closeHistoryMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked:
                                    shell.notificationCenterOpen = false
                            }
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        color: shell.backgroundAlt
                        radius: shell.panelRadius
                        border.width: shell.borderWidth
                        border.color: shell.surfaceHover

                        ListView {
                            id: notificationList

                            anchors {
                                fill: parent
                                margins: 10
                            }

                            spacing: 8
                            clip: true
                            model:
                                server.trackedNotifications.values
                                    .slice()
                                    .reverse()

                            delegate: Rectangle {
                                id: historyItem

                                required property var modelData

                                width: notificationList.width
                                height:
                                    104
                                    + Math.min(2, modelData.actions.length) * 30
                                color: shell.surface
                                radius: shell.controlRadius
                                border.width: shell.borderWidth
                                border.color:
                                    component.accentFor(modelData)

                                Rectangle {
                                    anchors {
                                        left: parent.left
                                        top: parent.top
                                        bottom: parent.bottom
                                    }

                                    width: 5
                                    color:
                                        component.accentFor(
                                            historyItem.modelData
                                        )
                                }

                                ColumnLayout {
                                    anchors {
                                        fill: parent
                                        leftMargin: 16
                                        rightMargin: 10
                                        topMargin: 10
                                        bottomMargin: 10
                                    }

                                    spacing: 5

                                    RowLayout {
                                        Layout.fillWidth: true

                                        Text {
                                            Layout.fillWidth: true
                                            text:
                                                historyItem.modelData.appName
                                                || "SYSTEM EVENT"
                                            color:
                                                component.accentFor(
                                                    historyItem.modelData
                                                )
                                            font.family:
                                                "JetBrainsMono Nerd Font"
                                            font.pixelSize: Math.round(8 * shell.fontScale)
                                            font.weight: Font.Black
                                            font.letterSpacing: 1.3
                                            elide: Text.ElideRight
                                        }

                                        Rectangle {
                                            width: 28
                                            height: 24
                                            radius: shell.controlRadius
                                            color:
                                                dismissHistoryMouse.containsMouse
                                                    ? shell.uiPalette[0]
                                                    : shell.surfaceAlt

                                            Text {
                                                anchors.centerIn: parent
                                                text: "×"
                                                color:
                                                    dismissHistoryMouse.containsMouse
                                                        ? shell.ink
                                                        : shell.text
                                                font.pixelSize: Math.round(16 * shell.fontScale)
                                                font.weight: Font.Black
                                            }

                                            MouseArea {
                                                id: dismissHistoryMouse
                                                anchors.fill: parent
                                                hoverEnabled: true
                                                cursorShape:
                                                    Qt.PointingHandCursor
                                                onClicked:
                                                    historyItem
                                                        .modelData
                                                        .dismiss()
                                            }
                                        }
                                    }

                                    Text {
                                        Layout.fillWidth: true
                                        text:
                                            historyItem.modelData.summary
                                            || "UNTITLED NOTIFICATION"
                                        color: shell.textStrong
                                        font.family:
                                            "JetBrainsMono Nerd Font"
                                        font.pixelSize: Math.round(11 * shell.fontScale)
                                        font.weight: Font.Black
                                        elide: Text.ElideRight
                                    }

                                    Text {
                                        Layout.fillWidth: true
                                        text:
                                            historyItem.modelData.body
                                            || ""
                                        textFormat: Text.PlainText
                                        color: shell.muted
                                        font.family:
                                            "JetBrainsMono Nerd Font"
                                        font.pixelSize: Math.round(8 * shell.fontScale)
                                        font.weight: Font.Medium
                                        wrapMode: Text.Wrap
                                        elide: Text.ElideRight
                                        maximumLineCount: 2
                                    }

                                    Row {
                                        Layout.fillWidth: true
                                        spacing: 6
                                        visible:
                                            historyItem
                                                .modelData
                                                .actions
                                                .length > 0

                                        Repeater {
                                            model:
                                                historyItem
                                                    .modelData
                                                    .actions
                                                    .slice(0, 2)

                                            Rectangle {
                                                id: actionButton

                                                required property var modelData

                                                width: Math.min(
                                                    150,
                                                    Math.max(
                                                        70,
                                                        actionLabel
                                                            .implicitWidth
                                                        + 22
                                                    )
                                                )
                                                height: 26
                                                radius: shell.controlRadius
                                                color:
                                                    actionMouse.containsMouse
                                                        ? shell.uiPalette[3]
                                                        : shell.surfaceAlt
                                                border.width:
                                                    actionMouse.containsMouse
                                                        ? 0
                                                        : 1
                                                border.color: shell.borderStrong

                                                Text {
                                                    id: actionLabel
                                                    anchors.centerIn: parent
                                                    text:
                                                        actionButton
                                                            .modelData
                                                            .text
                                                        || "ACTION"
                                                    color:
                                                        actionMouse.containsMouse
                                                            ? shell.ink
                                                            : shell.text
                                                    font.family:
                                                        "JetBrainsMono Nerd Font"
                                                    font.pixelSize: Math.round(7 * shell.fontScale)
                                                    font.weight: Font.Black
                                                    font.letterSpacing: 0.8
                                                    elide: Text.ElideRight
                                                }

                                                MouseArea {
                                                    id: actionMouse
                                                    anchors.fill: parent
                                                    hoverEnabled: true
                                                    cursorShape:
                                                        Qt.PointingHandCursor
                                                    onClicked:
                                                        actionButton
                                                            .modelData
                                                            .invoke()
                                                }
                                            }
                                        }
                                    }
                                }
                            }

                            Text {
                                anchors.centerIn: parent
                                visible: component.notificationCount === 0
                                text: "NO RETAINED SIGNALS"
                                color: shell.dim
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: Math.round(10 * shell.fontScale)
                                font.weight: Font.Black
                                font.letterSpacing: 1.8
                            }
                        }

                        Rectangle {
                            anchors {
                                top: parent.top
                                right: parent.right
                                bottom: parent.bottom
                                topMargin: 10
                                rightMargin: 4
                                bottomMargin: 10
                            }

                            width: 3
                            radius: shell.controlRadius
                            color: shell.surface
                            visible:
                                notificationList.contentHeight
                                > notificationList.height

                            Rectangle {
                                width: parent.width
                                height: Math.max(
                                    24,
                                    parent.height
                                    * notificationList
                                        .visibleArea
                                        .heightRatio
                                )
                                y: Math.max(
                                    0,
                                    Math.min(
                                        parent.height - height,
                                        parent.height
                                        * notificationList
                                            .visibleArea
                                            .yPosition
                                    )
                                )
                                radius: shell.controlRadius
                                color: shell.uiPalette[4]

                                Behavior on y {
                                    NumberAnimation {
                                        duration: 90
                                    }
                                }
                            }
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 18

                        Rectangle {
                            width: 8
                            height: 8
                            radius: shell.controlRadius
                            color: shell.doNotDisturb
                                ? shell.uiPalette[2]
                                : shell.uiPalette[3]
                        }

                        Text {
                            text: shell.doNotDisturb
                                ? "POPUPS SILENCED // HISTORY ACTIVE"
                                : "NOTIFICATION LINK ONLINE"
                            color: shell.muted
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: Math.round(7 * shell.fontScale)
                            font.weight: Font.Black
                            font.letterSpacing: 1.2
                        }

                        Item {
                            Layout.fillWidth: true
                        }

                        Text {
                            text: "RIGHT-CLICK BAR ICON FOR DND"
                            color: shell.dim
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: Math.round(7 * shell.fontScale)
                            font.weight: Font.Bold
                            font.letterSpacing: 1
                        }
                    }
                }
            }
        }
    }
}

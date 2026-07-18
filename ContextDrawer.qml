import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Services.Mpris

Scope {
    id: component

    required property var shell

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: drawerWindow

            required property var modelData

            screen: modelData

            visible:
                modelData.name === shell.resolvedBarMonitor
                && shell.drawerOpen

            anchors {
                left: true
                right: true
                top: shell.barPosition === "TOP"
                bottom: shell.barPosition !== "TOP"
            }

            margins {
                left: 170
                right: 170
                top: shell.barPosition === "TOP" ? shell.barHeight + 28 : 0
                bottom: shell.barPosition === "BOTTOM" ? shell.barHeight + 28 : 0
            }

            implicitHeight: 258
            exclusiveZone: 0
            aboveWindows: true
            color: "transparent"

            Rectangle {
                anchors.fill: parent

                color: shell.backgroundAlt
                radius: shell.panelRadius

                border.width: 2
                border.color: shell.contextAccent

                clip: true

                Row {
                    anchors {
                        top: parent.top
                        left: parent.left
                        right: parent.right
                    }

                    height: 6
                    spacing: 0

                    Repeater {
                        model: 7

                        Rectangle {
                            required property int index

                            width: drawerWindow.width / 7
                            height: 6
                            color: shell.uiPalette[index]
                        }
                    }
                }

                Rectangle {
                    anchors {
                        left: parent.left
                        top: parent.top
                        bottom: parent.bottom
                        topMargin: 6
                    }

                    width: 12
                    color: shell.contextAccent
                }

                RowLayout {
                    anchors {
                        fill: parent
                        topMargin: 22
                        bottomMargin: 18
                        leftMargin: 32
                        rightMargin: 26
                    }

                    spacing: 24

                    /*
                     * ART / FOCUS TILE
                     */
                    Rectangle {
                        visible: shell.showAlbumArt
                        Layout.preferredWidth: shell.showAlbumArt ? 194 : 0
                        Layout.fillHeight: true

                        color: shell.hasMedia
                            ? shell.surface
                            : shell.contextAccent

                        radius: shell.panelRadius
                        clip: true

                        Image {
                            anchors.fill: parent

                            source:
                                shell.hasMedia
                                && shell.player !== null
                                    ? shell.player.trackArtUrl
                                    : ""

                            visible:
                                shell.hasMedia
                                && shell.player !== null
                                && shell.player.trackArtUrl !== ""

                            fillMode: Image.PreserveAspectCrop
                            asynchronous: true
                            cache: false
                        }

                        Column {
                            anchors {
                                left: parent.left
                                right: parent.right
                                bottom: parent.bottom
                                margins: 14
                            }

                            visible:
                                !shell.hasMedia
                                || shell.player === null
                                || shell.player.trackArtUrl === ""

                            spacing: 4

                            Text {
                                text: shell.hasMedia ? "♫" : "↗"

                                color: shell.hasMedia
                                    ? shell.contextAccent
                                    : shell.ink

                                font.family:
                                    "JetBrainsMono Nerd Font"

                                font.pixelSize: Math.round(52 * shell.fontScale)
                                font.weight: Font.Black
                            }

                            Text {
                                width: parent.width

                                text: shell.hasMedia
                                    ? "AUDIO CHANNEL"
                                    : "FOCUS CHANNEL"

                                color: shell.hasMedia
                                    ? shell.text
                                    : shell.ink

                                font.family:
                                    "JetBrainsMono Nerd Font"

                                font.pixelSize: Math.round(10 * shell.fontScale)
                                font.weight: Font.Black
                                font.letterSpacing: 1.5
                            }
                        }

                        Rectangle {
                            anchors {
                                top: parent.top
                                right: parent.right
                                margins: 10
                            }

                            width: 40
                            height: 40
                            radius: shell.controlRadius

                            color: shell.mediaPlaying
                                ? shell.uiPalette[3]
                                : shell.uiPalette[1]

                            Text {
                                anchors.centerIn: parent

                                text: shell.mediaPlaying
                                    ? "LIVE"
                                    : "HOLD"

                                color: shell.ink

                                font.family:
                                    "JetBrainsMono Nerd Font"

                                font.pixelSize: Math.round(8 * shell.fontScale)
                                font.weight: Font.Black
                                font.letterSpacing: 1
                            }
                        }
                    }

                    /*
                     * PRIMARY CONTEXT INFORMATION
                     */
                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        spacing: 9

                        RowLayout {
                            Layout.fillWidth: true

                            Text {
                                text: shell.hasMedia
                                    ? "NOW TRANSMITTING"
                                    : "CURRENT FOCUS"

                                color: shell.contextAccent

                                font.family:
                                    "JetBrainsMono Nerd Font"

                                font.pixelSize: Math.round(10 * shell.fontScale)
                                font.weight: Font.Black
                                font.letterSpacing: 2
                            }

                            Item {
                                Layout.fillWidth: true
                            }

                            Text {
                                text:
                                    shell.hasMedia
                                        ? (
                                            shell.mediaPlaying
                                                ? "PLAYING"
                                                : "PAUSED"
                                        )
                                        : (
                                            "WORKSPACE "
                                            + (
                                                Hyprland.focusedWorkspace
                                                !== null
                                                    ? Hyprland
                                                        .focusedWorkspace
                                                        .id
                                                    : "—"
                                            )
                                        )

                                color: shell.muted

                                font.family:
                                    "JetBrainsMono Nerd Font"

                                font.pixelSize: Math.round(9 * shell.fontScale)
                                font.weight: Font.Bold
                                font.letterSpacing: 1.4
                            }
                        }

                        Text {
                            Layout.fillWidth: true

                            text: shell.contextTitle

                            color: shell.textStrong

                            font.family:
                                "JetBrainsMono Nerd Font"

                            font.pixelSize: Math.round(26 * shell.fontScale)
                            font.weight: Font.Black
                            font.letterSpacing: 0.4

                            elide: Text.ElideRight
                            maximumLineCount: 1
                        }

                        Text {
                            Layout.fillWidth: true

                            text: shell.contextSubtitle.toUpperCase()

                            color: shell.muted

                            font.family:
                                "JetBrainsMono Nerd Font"

                            font.pixelSize: Math.round(11 * shell.fontScale)
                            font.weight: Font.Bold
                            font.letterSpacing: 1.4

                            elide: Text.ElideRight
                            maximumLineCount: 1
                        }

                        Item {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                        }

                        /*
                         * MEDIA PROGRESS
                         */
                        ColumnLayout {
                            Layout.fillWidth: true

                            visible: shell.hasMedia
                            spacing: 6

                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 10

                                color: shell.surfaceAlt
                                radius: shell.controlRadius
                                clip: true

                                Rectangle {
                                    width:
                                        parent.width
                                        * shell.mediaProgress

                                    height: parent.height
                                    color: shell.contextAccent
                                    radius: shell.controlRadius

                                    Behavior on width {
                                        NumberAnimation {
                                            duration: 450
                                            easing.type:
                                                Easing.OutCubic
                                        }
                                    }
                                }

                                Row {
                                    anchors.fill: parent
                                    spacing: 12

                                    Repeater {
                                        model: 28

                                        Rectangle {
                                            required property int index

                                            width: 2
                                            height: parent.height

                                            color: shell.backgroundAlt
                                            opacity: 0.45
                                        }
                                    }
                                }
                            }

                            RowLayout {
                                Layout.fillWidth: true

                                Text {
                                    text:
                                        shell.player !== null
                                            ? shell.formatSeconds(
                                                shell.player.position
                                            )
                                            : "00:00"

                                    color: shell.muted

                                    font.family:
                                        "JetBrainsMono Nerd Font"

                                    font.pixelSize: Math.round(9 * shell.fontScale)
                                    font.weight: Font.Bold
                                }

                                Item {
                                    Layout.fillWidth: true
                                }

                                Text {
                                    text:
                                        shell.player !== null
                                            ? shell.formatSeconds(
                                                shell.player.length
                                            )
                                            : "00:00"

                                    color: shell.muted

                                    font.family:
                                        "JetBrainsMono Nerd Font"

                                    font.pixelSize: Math.round(9 * shell.fontScale)
                                    font.weight: Font.Bold
                                }
                            }
                        }

                        /*
                         * REAL MEDIA CONTROLS
                         */
                        Row {
                            Layout.alignment: Qt.AlignLeft
                            spacing: 8
                            visible: shell.hasMedia

                            Rectangle {
                                width: 72
                                height: 36
                                radius: shell.controlRadius

                                color: previousMouse.containsMouse
                                    ? shell.uiPalette[1]
                                    : shell.surfaceAlt

                                border.width:
                                    previousMouse.containsMouse ? 0 : shell.borderWidth

                                border.color: shell.borderStrong

                                Text {
                                    anchors.centerIn: parent
                                    text: "PREV"
                                    color: previousMouse.containsMouse
                                        ? shell.ink
                                        : shell.text

                                    font.family:
                                        "JetBrainsMono Nerd Font"

                                    font.pixelSize: Math.round(9 * shell.fontScale)
                                    font.weight: Font.Black
                                    font.letterSpacing: 1
                                }

                                MouseArea {
                                    id: previousMouse

                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape:
                                        Qt.PointingHandCursor

                                    onClicked: {
                                        if (
                                            shell.player !== null
                                            && shell.player
                                                .canGoPrevious
                                        ) {
                                            shell.player.previous()
                                        }
                                    }
                                }
                            }

                            Rectangle {
                                width: 102
                                height: 36
                                radius: shell.controlRadius

                                color: playMouse.containsMouse
                                    ? shell.contextAccent
                                    : shell.text

                                Text {
                                    anchors.centerIn: parent

                                    text: shell.mediaPlaying
                                        ? "PAUSE"
                                        : "PLAY"

                                    color: shell.ink

                                    font.family:
                                        "JetBrainsMono Nerd Font"

                                    font.pixelSize: Math.round(10 * shell.fontScale)
                                    font.weight: Font.Black
                                    font.letterSpacing: 1.2
                                }

                                MouseArea {
                                    id: playMouse

                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape:
                                        Qt.PointingHandCursor

                                    onClicked: {
                                        if (
                                            shell.player !== null
                                            && shell.player
                                                .canTogglePlaying
                                        ) {
                                            shell.player
                                                .togglePlaying()
                                        }
                                    }
                                }
                            }

                            Rectangle {
                                width: 72
                                height: 36
                                radius: shell.controlRadius

                                color: nextMouse.containsMouse
                                    ? shell.uiPalette[3]
                                    : shell.surfaceAlt

                                border.width:
                                    nextMouse.containsMouse ? 0 : shell.borderWidth

                                border.color: shell.borderStrong

                                Text {
                                    anchors.centerIn: parent
                                    text: "NEXT"
                                    color: nextMouse.containsMouse
                                        ? shell.ink
                                        : shell.text

                                    font.family:
                                        "JetBrainsMono Nerd Font"

                                    font.pixelSize: Math.round(9 * shell.fontScale)
                                    font.weight: Font.Black
                                    font.letterSpacing: 1
                                }

                                MouseArea {
                                    id: nextMouse

                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape:
                                        Qt.PointingHandCursor

                                    onClicked: {
                                        if (
                                            shell.player !== null
                                            && shell.player.canGoNext
                                        ) {
                                            shell.player.next()
                                        }
                                    }
                                }
                            }
                        }

                        /*
                         * FOCUS MODE ACTIONS
                         */
                        Row {
                            Layout.alignment: Qt.AlignLeft
                            spacing: 8
                            visible: !shell.hasMedia

                            Repeater {
                                model: [
                                    {
                                        label: "LAUNCHER",
                                        command: "__chroma_launcher__",
                                        colour: shell.uiPalette[0]
                                    },
                                    {
                                        label: "FILES",
                                        command: "exec thunar",
                                        colour: shell.uiPalette[3]
                                    }
                                ]

                                Rectangle {
                                    id: actionButton

                                    required property var modelData

                                    width: 100
                                    height: 36
                                    radius: shell.controlRadius

                                    color: actionMouse.containsMouse
                                        ? modelData.colour
                                        : shell.surfaceAlt

                                    border.width:
                                        actionMouse.containsMouse ? 0 : shell.borderWidth

                                    border.color: shell.borderStrong

                                    Text {
                                        anchors.centerIn: parent

                                        text: actionButton
                                            .modelData
                                            .label

                                        color: actionMouse.containsMouse
                                            ? shell.ink
                                            : shell.text

                                        font.family:
                                            "JetBrainsMono Nerd Font"

                                        font.pixelSize: Math.round(9 * shell.fontScale)
                                        font.weight: Font.Black
                                        font.letterSpacing: 1
                                    }

                                    MouseArea {
                                        id: actionMouse

                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape:
                                            Qt.PointingHandCursor

                                        onClicked: {
                                            if (
                                                actionButton
                                                    .modelData
                                                    .command
                                                === "__chroma_launcher__"
                                            ) {
                                                shell.launcherOpen = true
                                            } else {
                                                Hyprland.dispatch(
                                                    actionButton
                                                        .modelData
                                                        .command
                                                )
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }

                    /*
                     * REAL PIPEWIRE SPECTRUM
                     */
                    Rectangle {
                        Layout.preferredWidth: 236
                        Layout.fillHeight: true

                        color: shell.surface
                        radius: shell.panelRadius

                        border.width: shell.borderWidth
                        border.color: shell.surfaceHover

                        ColumnLayout {
                            anchors {
                                fill: parent
                                margins: 15
                            }

                            spacing: 10

                            RowLayout {
                                Layout.fillWidth: true

                                Column {
                                    spacing: 1

                                    Text {
                                        text: "LIVE SPECTRUM"
                                        color: shell.text

                                        font.family:
                                            "JetBrainsMono Nerd Font"

                                        font.pixelSize: Math.round(10 * shell.fontScale)
                                        font.weight: Font.Black
                                        font.letterSpacing: 1.5
                                    }

                                    Text {
                                        text:
                                            shell.spectrumAvailable
                                                ? "PIPEWIRE / CAVA"
                                                : "WAITING FOR AUDIO"

                                        color: shell.muted

                                        font.family:
                                            "JetBrainsMono Nerd Font"

                                        font.pixelSize: Math.round(8 * shell.fontScale)
                                        font.weight: Font.Bold
                                        font.letterSpacing: 1.2
                                    }
                                }

                                Item {
                                    Layout.fillWidth: true
                                }

                                Rectangle {
                                    width: 10
                                    height: 10
                                    radius: shell.controlRadius

                                    color:
                                        shell.spectrumAvailable
                                            ? shell.contextAccent
                                            : shell.surfaceHover
                                }
                            }

                            Item {
                                Layout.fillWidth: true
                                Layout.fillHeight: true

                                SpectrumBars {
                                    visible: shell.showSpectrum
                                    anchors {
                                        left: parent.left
                                        right: parent.right
                                        bottom: parent.bottom
                                    }

                                    height: parent.height

                                    values: shell.spectrumValues
                                    palette: shell.visualizerPalette
                                    active:
                                        shell.hasMedia
                                        && shell.spectrumAvailable

                                    barWidth: Math.max(
                                        2,
                                        Math.min(
                                            7,
                                            (width - Math.max(0, values.length - 1) * barSpacing)
                                            / Math.max(1, values.length)
                                        )
                                    )
                                    barSpacing: 3
                                    minimumBarHeight: 3
                                }
                            }

                            RowLayout {
                                Layout.fillWidth: true

                                Text {
                                    text: "LOW"
                                    color: shell.dim
                                    font.family: "JetBrainsMono Nerd Font"
                                    font.pixelSize: Math.round(8 * shell.fontScale)
                                    font.weight: Font.Bold
                                    font.letterSpacing: 1
                                }

                                Item {
                                    Layout.fillWidth: true
                                }

                                Text {
                                    text: "MID"
                                    color: shell.dim
                                    font.family: "JetBrainsMono Nerd Font"
                                    font.pixelSize: Math.round(8 * shell.fontScale)
                                    font.weight: Font.Bold
                                    font.letterSpacing: 1
                                }

                                Item {
                                    Layout.fillWidth: true
                                }

                                Text {
                                    text: "HIGH"
                                    color: shell.dim
                                    font.family: "JetBrainsMono Nerd Font"
                                    font.pixelSize: Math.round(8 * shell.fontScale)
                                    font.weight: Font.Bold
                                    font.letterSpacing: 1
                                }
                            }
                        }
                    }
                }

                Rectangle {
                    anchors {
                        top: parent.top
                        right: parent.right
                        margins: 14
                    }

                    width: 34
                    height: 34
                    radius: shell.controlRadius

                    color: closeMouse.containsMouse
                        ? shell.uiPalette[0]
                        : shell.surfaceAlt

                    Text {
                        anchors.centerIn: parent
                        text: "×"

                        color: closeMouse.containsMouse
                            ? shell.ink
                            : shell.text

                        font.pixelSize: Math.round(20 * shell.fontScale)
                        font.weight: Font.Black
                    }

                    MouseArea {
                        id: closeMouse

                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor

                        onClicked:
                            shell.drawerOpen = false
                    }
                }
            }
        }
    }
}

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
            id: barWindow

            required property var modelData

            screen: modelData
            visible: modelData.name === shell.resolvedBarMonitor

            anchors {
                left: true
                right: true
                top: shell.barPosition === "TOP"
                bottom: shell.barPosition !== "TOP"
            }

            margins {
                left: shell.barOuterMargin
                right: shell.barOuterMargin
                top: shell.barPosition === "TOP" ? shell.barOuterMargin : 0
                bottom: shell.barPosition === "BOTTOM" ? shell.barOuterMargin : 0
            }

            implicitHeight: shell.barHeight
            exclusiveZone: 0
            aboveWindows: true
            color: "transparent"

            RowLayout {
                anchors.fill: parent
                spacing: shell.barGap

                /*
                 * IDENTITY
                 */
                Rectangle {
                    id: identityBlock

                    Layout.preferredWidth:
                        identityMouse.containsMouse
                            ? shell.identityHoverWidth
                            : shell.identityWidth

                    Layout.fillHeight: true

                    color: identityMouse.containsMouse
                        ? shell.uiPalette[4]
                        : shell.uiPalette[0]

                    radius: shell.moduleRadius

                    Behavior on Layout.preferredWidth {
                        NumberAnimation {
                            duration: Math.round(shell.animationDuration * 1.13)
                            easing.type: Easing.OutCubic
                        }
                    }

                    Behavior on color {
                        ColorAnimation {
                            duration: shell.animationDuration
                        }
                    }

                    RowLayout {
                        anchors {
                            fill: parent
                            leftMargin: shell.identityHorizontalPadding
                            rightMargin: shell.identityHorizontalPadding
                        }

                        Column {
                            Layout.alignment: Qt.AlignVCenter
                            spacing: 0

                            Text {
                                text: "CHROMA/04"
                                color: shell.ink

                                font.family:
                                    "JetBrainsMono Nerd Font"

                                font.pixelSize: Math.round(17 * shell.fontScale)
                                font.weight: Font.Black
                                font.letterSpacing: 1
                            }

                            Text {
                                text: "KINETIC EDITION"
                                color: shell.ink
                                opacity: 0.65

                                font.family:
                                    "JetBrainsMono Nerd Font"

                                font.pixelSize: Math.round(8 * shell.fontScale)
                                font.weight: Font.Bold
                                font.letterSpacing: 1.6
                            }
                        }

                        Item {
                            Layout.fillWidth: true
                        }

                        Text {
                            text: "↗"
                            color: shell.ink

                            font.pixelSize: Math.round(24 * shell.fontScale)
                            font.weight: Font.Black

                            rotation:
                                identityMouse.containsMouse
                                    ? 45
                                    : 0

                            Behavior on rotation {
                                NumberAnimation {
                                    duration: Math.round(shell.animationDuration * 1.2)
                                    easing.type: Easing.OutBack
                                }
                            }
                        }
                    }

                    MouseArea {
                        id: identityMouse

                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor

                        onClicked:
                            shell.launcherOpen =
                                !shell.launcherOpen
                    }
                }

                /*
                 * WORKSPACE RAIL
                 */
                Rectangle {
                    visible: shell.showWorkspaces
                    Layout.preferredWidth: shell.workspaceRailWidth
                    Layout.fillHeight: true

                    color: shell.backgroundAlt
                    radius: shell.moduleRadius

                    border.width: shell.borderWidth
                    border.color: shell.border

                    Row {
                        anchors {
                            fill: parent
                            leftMargin: shell.workspaceRailPadding
                            rightMargin: shell.workspaceRailPadding
                        }
                        spacing: shell.workspaceGap

                        Repeater {
                            model: shell.workspaceCount

                            Item {
                                id: workspaceSlot

                                required property int index

                                width: shell.workspaceSlotWidth
                                height: parent.height

                                Rectangle {
                                    id: workspaceButton

                                    property int number: workspaceSlot.index + 1

                                    property var workspaceObject:
                                        shell.workspaceFor(number)

                                    property bool active:
                                        Hyprland.focusedWorkspace !== null
                                        && Hyprland.focusedWorkspace.id === number

                                    property bool occupied:
                                        workspaceObject !== null
                                        && workspaceObject.toplevels.values.length > 0

                                    anchors.centerIn: parent

                                    width:
                                        active
                                            ? shell.workspaceActiveWidth
                                            : workspaceMouse.containsMouse
                                                ? shell.workspaceHoverWidth
                                                : shell.workspaceButtonWidth

                                    height:
                                        active
                                            ? shell.workspaceActiveHeight
                                            : shell.workspaceButtonHeight

                                    radius: shell.workspaceRadius

                                    color:
                                        active
                                            ? shell.uiPalette[
                                                workspaceSlot.index
                                                % shell.uiPalette.length
                                            ]
                                            : workspaceMouse.containsMouse
                                                ? shell.surfaceHover
                                                : shell.surface

                                    border.width:
                                        active ? 0 : shell.borderWidth
                                    border.color: shell.borderStrong

                                    Behavior on width {
                                        NumberAnimation {
                                            duration: shell.animationDuration
                                            easing.type: Easing.OutCubic
                                        }
                                    }

                                    Behavior on height {
                                        NumberAnimation {
                                            duration: shell.animationDuration
                                            easing.type: Easing.OutCubic
                                        }
                                    }

                                    Behavior on color {
                                        ColorAnimation {
                                            duration: shell.animationDuration
                                        }
                                    }

                                    Text {
                                        anchors.centerIn: parent
                                        visible: shell.workspaceStyle !== "DOTS"

                                        text:
                                            workspaceButton.number < 10
                                                ? "0" + workspaceButton.number
                                                : workspaceButton.number

                                        color:
                                            workspaceButton.active
                                                ? shell.ink
                                                : shell.text

                                        font.family: "JetBrainsMono Nerd Font"
                                        font.pixelSize: Math.round(
                                            10 * shell.fontScale
                                        )
                                        font.weight: Font.Black
                                    }

                                    Rectangle {
                                        visible: shell.workspaceStyle !== "DOTS"
                                        anchors {
                                            bottom: parent.bottom
                                            horizontalCenter:
                                                parent.horizontalCenter
                                            bottomMargin: Math.max(3, Math.round(
                                                shell.barHeight * 0.055
                                            ))
                                        }

                                        width:
                                            workspaceButton.occupied
                                                ? Math.max(8, Math.round(
                                                    workspaceButton.width * 0.30
                                                ))
                                                : Math.max(2, Math.round(
                                                    workspaceButton.width * 0.08
                                                ))

                                        height: Math.max(2, shell.borderWidth)
                                        radius: shell.microRadius

                                        color:
                                            workspaceButton.active
                                                ? shell.ink
                                                : shell.uiPalette[
                                                    workspaceSlot.index
                                                    % shell.uiPalette.length
                                                ]

                                        opacity:
                                            workspaceButton.occupied ? 1 : 0.25

                                        Behavior on width {
                                            NumberAnimation {
                                                duration: shell.animationDuration
                                            }
                                        }
                                    }

                                    MouseArea {
                                        id: workspaceMouse

                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor

                                        onClicked:
                                            Hyprland.dispatch(
                                                "workspace "
                                                + workspaceButton.number
                                            )
                                    }
                                }
                            }
                        }
                    }
                }

                Item {
                    Layout.fillWidth: true
                    Layout.minimumWidth: 12
                }

                /*
                 * CONTEXT CANVAS
                 */
                Rectangle {
                    id: contextCanvas

                    visible: shell.showMedia
                    Layout.preferredWidth: shell.mediaWidth
                    Layout.minimumWidth: shell.mediaWidth
                    Layout.maximumWidth: shell.mediaWidth
                    Layout.fillHeight: true

                    color: contextMouse.containsMouse
                        ? shell.surface
                        : shell.backgroundAlt

                    radius: shell.moduleRadius

                    border.width: shell.borderWidth
                    border.color:
                        shell.drawerOpen
                            ? shell.contextAccent
                            : shell.border

                    Behavior on color {
                        ColorAnimation {
                            duration: shell.animationDuration
                        }
                    }


                    Rectangle {
                        id: mediaProgressTrack

                        anchors {
                            left: parent.left
                            right: parent.right
                            bottom: parent.bottom
                            leftMargin: shell.mediaProgressHorizontalInset
                            rightMargin: shell.mediaProgressHorizontalInset
                            bottomMargin: shell.mediaProgressBottomInset
                        }

                        height: shell.mediaProgressHeight
                        radius: shell.mediaProgressRadius
                        color: shell.surfaceHover
                        clip: true

                        Rectangle {
                            anchors {
                                left: parent.left
                                top: parent.top
                                bottom: parent.bottom
                            }

                            width:
                                shell.hasMedia
                                    ? Math.max(
                                        0,
                                        Math.min(
                                            parent.width,
                                            parent.width * shell.mediaProgress
                                        )
                                    )
                                    : 0

                            radius: Math.min(
                                mediaProgressTrack.radius,
                                width / 2,
                                height / 2
                            )
                            color: shell.contextAccent

                            Behavior on width {
                                NumberAnimation {
                                    duration: 400
                                    easing.type: Easing.OutCubic
                                }
                            }
                        }
                    }

                    RowLayout {
                        anchors {
                            fill: parent
                            leftMargin: shell.mediaHorizontalPadding
                            rightMargin: shell.mediaHorizontalPadding
                            bottomMargin: Math.max(2, shell.borderWidth * 2)
                        }

                        spacing: shell.mediaContentGap

                        Rectangle {
                            id: compactAlbumArt

                            Layout.preferredWidth: shell.albumArtSize
                            Layout.preferredHeight: shell.albumArtSize
                            Layout.alignment: Qt.AlignVCenter

                            visible: shell.hasMedia && shell.showAlbumArt
                            color: shell.surface
                            radius: shell.controlRadius
                            border.width: shell.borderWidth
                            border.color: shell.border
                            clip: true

                            Image {
                                id: compactAlbumImage

                                anchors.fill: parent
                                source:
                                    shell.player !== null
                                        ? shell.player.trackArtUrl
                                        : ""
                                fillMode: Image.PreserveAspectCrop
                                asynchronous: true
                                cache: false
                                visible: status === Image.Ready
                            }

                            Text {
                                anchors.centerIn: parent
                                visible: compactAlbumImage.status !== Image.Ready
                                text: "♫"
                                color: shell.contextAccent
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: Math.round(20 * shell.fontScale)
                                font.weight: Font.Black
                            }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignVCenter

                            spacing: 1

                            Text {
                                Layout.fillWidth: true

                                text: shell.contextTitle

                                color: shell.text

                                font.family:
                                    "JetBrainsMono Nerd Font"

                                font.pixelSize: Math.round(13 * shell.fontScale)
                                font.weight: Font.Black
                                font.letterSpacing: 0.4

                                elide: Text.ElideRight
                            }

                            Text {
                                Layout.fillWidth: true

                                text:
                                    shell.contextSubtitle
                                        .toUpperCase()

                                color: shell.muted

                                font.family:
                                    "JetBrainsMono Nerd Font"

                                font.pixelSize: Math.round(8 * shell.fontScale)
                                font.weight: Font.Bold
                                font.letterSpacing: 1.4

                                elide: Text.ElideRight
                            }
                        }

                        SpectrumBars {
                            visible: shell.showSpectrum
                            Layout.preferredWidth:
                                shell.showSpectrum ? shell.spectrumWidth : 0
                            Layout.preferredHeight: shell.spectrumHeight
                            Layout.alignment: Qt.AlignVCenter

                            values: shell.spectrumValues
                            palette: shell.visualizerPalette
                            active:
                                shell.hasMedia
                                && shell.spectrumAvailable

                            barWidth: Math.max(
                                2,
                                Math.min(
                                    5,
                                    (width - Math.max(0, values.length - 1) * barSpacing)
                                    / Math.max(1, values.length)
                                )
                            )
                            barSpacing: shell.spectrumGap
                            minimumBarHeight: 2
                        }
                    }

                    MouseArea {
                        id: contextMouse

                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor

                        onClicked:
                            shell.drawerOpen =
                                !shell.drawerOpen
                    }
                }

                Item {
                    Layout.fillWidth: true
                    Layout.minimumWidth: 12
                }


                /*
                 * NOTIFICATIONS
                 */
                NotificationButton {
                    visible: shell.showNotifications
                    shell: component.shell
                    Layout.fillHeight: true
                }

                /*
                 * THEME ENGINE
                 */
                ThemeButton {
                    visible: shell.showThemes
                    shell: component.shell
                    Layout.fillHeight: true
                }

                /*
                 * CONTROL CENTRE
                 */
                Rectangle {
                    id: controlButton

                    visible: shell.showControl
                    Layout.preferredWidth:
                        controlMouse.containsMouse
                            ? shell.utilityHoverWidth
                            : shell.utilityWidth

                    Layout.fillHeight: true

                    color: shell.controlCenterOpen
                        ? shell.uiPalette[3]
                        : controlMouse.containsMouse
                            ? shell.uiPalette[4]
                            : shell.surface

                    radius: shell.moduleRadius
                    border.width:
                        shell.controlCenterOpen
                        || controlMouse.containsMouse
                            ? 0
                            : shell.borderWidth
                    border.color: shell.border

                    Behavior on Layout.preferredWidth {
                        NumberAnimation {
                            duration: Math.round(shell.animationDuration * 1.13)
                            easing.type: Easing.OutCubic
                        }
                    }

                    Behavior on color {
                        ColorAnimation {
                            duration: shell.animationDuration
                        }
                    }

                    RowLayout {
                        anchors.centerIn: parent
                        spacing: 8

                        Column {
                            Layout.alignment: Qt.AlignVCenter
                            spacing: 3

                            Rectangle {
                                width: 11
                                height: 4
                                radius: shell.controlRadius
                                color:
                                    shell.controlCenterOpen
                                    || controlMouse.containsMouse
                                        ? shell.ink
                                        : shell.uiPalette[0]
                            }

                            Rectangle {
                                width: 17
                                height: 4
                                radius: shell.controlRadius
                                color:
                                    shell.controlCenterOpen
                                    || controlMouse.containsMouse
                                        ? shell.ink
                                        : shell.uiPalette[4]
                            }

                            Rectangle {
                                width: 8
                                height: 4
                                radius: shell.controlRadius
                                color:
                                    shell.controlCenterOpen
                                    || controlMouse.containsMouse
                                        ? shell.ink
                                        : shell.uiPalette[3]
                            }
                        }

                        Text {
                            visible: controlMouse.containsMouse
                            text: "CONTROL"
                            color: shell.ink
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: Math.round(9 * shell.fontScale)
                            font.weight: Font.Black
                            font.letterSpacing: 1
                        }
                    }

                    MouseArea {
                        id: controlMouse

                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor

                        onClicked:
                            shell.controlCenterOpen =
                                !shell.controlCenterOpen
                    }
                }

                /*
                 * CLOCK
                 */
                Rectangle {
                    visible: shell.showClock
                    Layout.preferredWidth: shell.clockWidth
                    Layout.fillHeight: true

                    color:
                        shell.uiPalette[
                            Math.floor(shell.tick / 22)
                            % shell.palette.length
                        ]

                    radius: shell.moduleRadius

                    Behavior on color {
                        ColorAnimation {
                            duration: 550
                        }
                    }

                    RowLayout {
                        anchors {
                            fill: parent
                            leftMargin: shell.clockHorizontalPadding
                            rightMargin: shell.clockHorizontalPadding
                        }

                        Column {
                            Layout.alignment: Qt.AlignVCenter
                            spacing: 0

                            Text {
                                text: Qt.formatDateTime(
                                    shell.now,
                                    shell.clockFormat === "12H"
                                        ? "hh:mm AP"
                                        : "HH:mm"
                                )

                                color: shell.ink

                                font.family:
                                    "JetBrainsMono Nerd Font"

                                font.pixelSize: Math.round(21 * shell.fontScale)
                                font.weight: Font.Black
                                font.letterSpacing: 1
                            }

                            Text {
                                visible: shell.showDate
                                text: Qt.formatDateTime(
                                    shell.now,
                                    shell.datePattern
                                ).toUpperCase()

                                color: shell.ink
                                opacity: 0.65

                                font.family:
                                    "JetBrainsMono Nerd Font"

                                font.pixelSize: Math.round(8 * shell.fontScale)
                                font.weight: Font.Bold
                                font.letterSpacing: 1.1
                            }
                        }

                        Item {
                            Layout.fillWidth: true
                        }

                        Rectangle {
                            width: 9
                            height: shell.clockSignalHeight
                            radius: shell.controlRadius
                            color: shell.ink
                        }
                    }
                }
            }
        }
    }
}

import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Mpris

Item {
    id: widget
    required property var shell
    required property var widgetData

    readonly property var player: shell.player
    readonly property string contentFont:
        String(widgetData.settings.fontFamily || "JetBrainsMono Nerd Font")
    readonly property real contentScale:
        Math.max(0.70, Math.min(1.80, Number(widgetData.settings.fontScale || 1.0)))

    RowLayout {
        anchors.fill: parent
        spacing: Math.max(10, Math.round(14 * widget.contentScale))

        Rectangle {
            visible: widgetData.settings.artwork !== false
            Layout.preferredWidth: Math.max(76, Math.min(widget.height - 8, 150))
            Layout.preferredHeight: Layout.preferredWidth
            color: shell.backgroundAlt
            border.width: shell.borderWidth
            border.color: shell.border
            radius: shell.controlRadius
            clip: true

            Image {
                id: albumImage
                anchors.fill: parent
                source: widget.player !== null ? widget.player.trackArtUrl : ""
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
                cache: true
                visible: albumImage.source !== ""
            }

            Rectangle {
                anchors.fill: parent
                visible: albumImage.source !== ""
                color: "#14000000"
            }

            Text {
                anchors.centerIn: parent
                visible: albumImage.source === ""
                text: "♫"
                color: shell.uiPalette[4]
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 34
                font.weight: Font.Black
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: Math.max(5, Math.round(7 * widget.contentScale))

            Text {
                Layout.fillWidth: true
                text: shell.hasMedia ? shell.contextTitle : "NO ACTIVE SIGNAL"
                color: shell.textStrong
                font.family: widget.contentFont
                font.pixelSize: Math.round(15 * shell.fontScale * widget.contentScale)
                font.weight: Font.Black
                elide: Text.ElideRight
            }

            Text {
                Layout.fillWidth: true
                text: shell.hasMedia ? shell.contextSubtitle : "START A MEDIA PLAYER"
                color: shell.muted
                font.family: widget.contentFont
                font.pixelSize: Math.round(8 * shell.fontScale * widget.contentScale)
                font.weight: Font.Bold
                elide: Text.ElideRight
            }

            Item { Layout.fillHeight: true }

            Rectangle {
                visible: widgetData.settings.progress !== false
                Layout.fillWidth: true
                Layout.preferredHeight: Math.max(5, Math.round(6 * widget.contentScale))
                color: shell.background
                radius: height / 2
                clip: true

                Rectangle {
                    width: parent.width * Math.max(0, Math.min(1, shell.mediaProgress))
                    height: parent.height
                    color: shell.uiPalette[6]
                    radius: parent.radius

                    Behavior on width {
                        NumberAnimation {
                            duration: 180
                            easing.type: Easing.OutCubic
                        }
                    }
                }
            }

            RowLayout {
                visible: widgetData.settings.controls !== false
                Layout.fillWidth: true
                spacing: 8

                Text {
                    text: shell.formatSeconds(widget.player !== null ? widget.player.position : 0)
                    color: shell.dim
                    font.family: widget.contentFont
                    font.pixelSize: Math.round(7 * shell.fontScale * widget.contentScale)
                    font.weight: Font.Bold
                }

                Item { Layout.fillWidth: true }

                Repeater {
                    model: ["PREVIOUS", "PLAY", "NEXT"]

                    Rectangle {
                        id: action
                        required property var modelData

                        Layout.preferredWidth:
                            action.modelData === "PLAY"
                                ? Math.round(48 * widget.contentScale)
                                : Math.round(38 * widget.contentScale)
                        Layout.preferredHeight: Math.round(34 * widget.contentScale)
                        color: actionMouse.containsMouse
                            ? shell.uiPalette[action.modelData === "PLAY" ? 4 : 0]
                            : shell.backgroundAlt
                        border.width: shell.borderWidth
                        border.color: shell.border
                        radius: shell.controlRadius

                        Text {
                            anchors.centerIn: parent
                            text: action.modelData === "PREVIOUS"
                                ? "󰒮"
                                : action.modelData === "NEXT"
                                    ? "󰒭"
                                    : (shell.mediaPlaying ? "󰏤" : "󰐊")
                            color: actionMouse.containsMouse ? shell.ink : shell.text
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: Math.round(
                                (action.modelData === "PLAY" ? 16 : 14)
                                * widget.contentScale
                            )
                        }

                        MouseArea {
                            id: actionMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                if (widget.player === null) return
                                if (action.modelData === "PREVIOUS" && widget.player.canGoPrevious) {
                                    widget.player.previous()
                                } else if (action.modelData === "NEXT" && widget.player.canGoNext) {
                                    widget.player.next()
                                } else if (action.modelData === "PLAY" && widget.player.canTogglePlaying) {
                                    widget.player.togglePlaying()
                                }
                            }
                        }
                    }
                }

                Item { Layout.fillWidth: true }

                Text {
                    text: shell.formatSeconds(widget.player !== null ? widget.player.length : 0)
                    color: shell.dim
                    font.family: widget.contentFont
                    font.pixelSize: Math.round(7 * shell.fontScale * widget.contentScale)
                    font.weight: Font.Bold
                }
            }
        }
    }
}

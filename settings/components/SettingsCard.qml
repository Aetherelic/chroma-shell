import QtQuick
import QtQuick.Layouts

Rectangle {
    id: card

    required property var shell

    property string title: ""
    property string subtitle: ""
    property color accent: shell.uiPalette[4]
    property int padding: shell.panelPadding

    default property alias content: body.data

    /*
     * Sharp and Technical retain the original edge-mounted signal rail.
     * Rounded styles move the rail inside the card so it no longer cuts
     * through the curved border.
     */
    readonly property bool roundedAccent:
        shell.cardRadius > 4

    readonly property int accentWidth: 3

    readonly property int accentX:
        roundedAccent
            ? Math.max(
                shell.borderWidth + 6,
                Math.round(shell.cardRadius * 0.55)
            )
            : 0

    readonly property int accentY:
        roundedAccent
            ? Math.max(
                8,
                Math.round(shell.cardRadius * 0.75)
            )
            : 0

    readonly property int accentGap:
        roundedAccent ? 8 : 0

    readonly property int contentLeftInset:
        accentX + accentWidth + accentGap

    implicitHeight:
        layout.implicitHeight + padding * 2

    color: shell.surface

    border.width: shell.borderWidth
    border.color: shell.border

    radius: shell.cardRadius

    Rectangle {
        id: accentRail

        x: card.accentX
        y: card.accentY

        width: card.accentWidth
        height: Math.max(
            0,
            card.height - card.accentY * 2
        )

        color: card.accent

        radius:
            card.roundedAccent
                ? Math.ceil(width / 2)
                : 0

        antialiasing: card.roundedAccent
    }

    ColumnLayout {
        id: layout

        anchors {
            fill: parent
            margins: card.padding
            leftMargin:
                card.padding + card.contentLeftInset
        }

        spacing: 14

        ColumnLayout {
            visible: card.title.length > 0

            Layout.fillWidth: true
            spacing: 0

            Text {
                Layout.fillWidth: true

                text: card.title.toUpperCase()
                color: shell.textStrong

                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize:
                    Math.round(12 * shell.fontScale)
                font.weight: Font.Black
                font.letterSpacing: 1
            }
        }

        ColumnLayout {
            id: body

            Layout.fillWidth: true
            spacing: 10
        }
    }
}

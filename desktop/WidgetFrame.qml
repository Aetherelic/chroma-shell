import QtQuick
import QtQuick.Layouts
import "widgets"

Rectangle {
    id: frame

    required property var shell
    required property var widgetData

    property bool editMode: false
    property bool selected: false

    readonly property string surfaceMode:
        String(widgetData.settings && widgetData.settings.surface
            ? widgetData.settings.surface
            : (widgetData.type === "clock" ? "TRANSPARENT" : "SOLID")).toUpperCase()
    readonly property bool transparentSurface: surfaceMode === "TRANSPARENT"
    readonly property bool translucentSurface: surfaceMode === "TRANSLUCENT"
    readonly property bool roundedGeometry: shell.panelRadius > 4
    readonly property int railInset:
        roundedGeometry ? Math.max(10, Math.round(shell.panelRadius * 0.72)) : 0
    readonly property int contentInset:
        transparentSurface ? 4 : Math.max(14, shell.panelPadding - 2)

    color:
        transparentSurface
            ? "transparent"
            : translucentSurface
                ? Qt.rgba(shell.surface.r, shell.surface.g, shell.surface.b, 0.76)
                : shell.surface

    border.width:
        editMode
            ? (selected ? Math.max(2, shell.borderWidth) : Math.max(1, shell.borderWidth))
            : (transparentSurface ? 0 : shell.borderWidth)
    border.color:
        editMode
            ? (selected ? shell.uiPalette[4] : Qt.rgba(shell.border.r, shell.border.g, shell.border.b, 0.72))
            : shell.border
    radius: transparentSurface && !editMode ? 0 : shell.panelRadius
    clip: true

    Rectangle {
        id: accentRail
        visible: !frame.transparentSurface
        x: frame.railInset
        y: frame.roundedGeometry ? 4 : 0
        width: Math.max(0, parent.width - frame.railInset * 2)
        height: 4
        color: shell.uiPalette[
            Math.abs(frame.widgetData.id.length + frame.widgetData.type.length)
            % shell.uiPalette.length
        ]
        radius: frame.roundedGeometry ? 2 : 0
        antialiasing: frame.roundedGeometry
    }

    Loader {
        anchors {
            fill: parent
            margins: frame.contentInset
            topMargin:
                frame.transparentSurface
                    ? frame.contentInset
                    : Math.max(
                        frame.contentInset,
                        frame.roundedGeometry
                            ? frame.railInset + 2
                            : shell.panelPadding + 2
                    )
        }
        sourceComponent:
            frame.widgetData.type === "music" ? musicComponent
            : frame.widgetData.type === "system" ? systemComponent
            : frame.widgetData.type === "cava" ? cavaComponent
            : clockComponent
    }

    Component {
        id: clockComponent
        ClockWidget { shell: frame.shell; widgetData: frame.widgetData }
    }
    Component {
        id: musicComponent
        MusicWidget { shell: frame.shell; widgetData: frame.widgetData }
    }
    Component {
        id: systemComponent
        SystemWidget { shell: frame.shell; widgetData: frame.widgetData }
    }
    Component {
        id: cavaComponent
        CavaWidget { shell: frame.shell; widgetData: frame.widgetData }
    }

    Rectangle {
        visible: frame.editMode
        anchors {
            top: parent.top
            left: parent.left
            margins: 8
        }
        width: Math.min(parent.width - 54, 180)
        height: 28
        color: frame.selected ? shell.uiPalette[4] : shell.backgroundAlt
        border.width: frame.selected ? 0 : shell.borderWidth
        border.color: shell.border
        radius: shell.controlRadius

        Text {
            anchors.centerIn: parent
            width: parent.width - 14
            text: frame.widgetData.type.toUpperCase()
            color: frame.selected ? shell.ink : shell.text
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: Math.round(7 * shell.fontScale)
            font.weight: Font.Black
            font.letterSpacing: 0.8
            elide: Text.ElideRight
            horizontalAlignment: Text.AlignHCenter
        }
    }
}

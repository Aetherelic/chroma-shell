import QtQuick

QtObject {
    id: tokens

    required property var settings

    readonly property string preset: settings.stylePreset

    readonly property int panelRadius:
        preset === "CAPSULE" ? 18
        : preset === "SOFT" ? 12
        : preset === "HYBRID" ? 2
        : preset === "TECHNICAL" ? 3
        : 1

    readonly property int windowRadius:
        preset === "CAPSULE" ? 20
        : preset === "SOFT" ? 14
        : preset === "HYBRID" ? 3
        : preset === "TECHNICAL" ? 4
        : 1

    readonly property int cardRadius:
        preset === "CAPSULE" ? 14
        : preset === "SOFT" ? 10
        : preset === "HYBRID" ? 3
        : preset === "TECHNICAL" ? 3
        : 1

    readonly property int controlRadius:
        preset === "CAPSULE" || preset === "HYBRID" ? 999
        : preset === "SOFT" ? 9
        : preset === "TECHNICAL" ? 3
        : 1

    readonly property int moduleRadius:
        preset === "CAPSULE" ? Math.round(settings.barHeight / 2)
        : preset === "SOFT" ? 12
        : preset === "HYBRID" ? 3
        : preset === "TECHNICAL" ? 4
        : 2

    readonly property int workspaceRadius:
        settings.workspaceStyle === "PILLS" ? 999
        : settings.workspaceStyle === "DOTS" ? 999
        : controlRadius

    readonly property int microRadius:
        preset === "CAPSULE" || preset === "HYBRID" ? 999 : 1

    readonly property int borderWidth: settings.borderThickness
    readonly property real fontScale: settings.fontScale
    readonly property real iconScale: settings.iconScale
    readonly property int panelPadding: settings.panelPadding
}

import QtQuick

QtObject {
    id: tokens

    required property var settings

    readonly property string preset: settings.stylePreset
    readonly property real densityScale:
        settings.density === "COMPACT" ? 0.90
        : settings.density === "SPACIOUS" ? 1.08
        : 1.0

    function clamp(value, minimum, maximum) {
        return Math.max(minimum, Math.min(maximum, value))
    }

    readonly property int panelRadius:
        preset === "CAPSULE" ? 16
        : preset === "SOFT" ? 12
        : preset === "HYBRID" ? 8
        : preset === "TECHNICAL" ? 4
        : 0

    readonly property int windowRadius:
        preset === "CAPSULE" ? 18
        : preset === "SOFT" ? 12
        : preset === "HYBRID" ? 8
        : preset === "TECHNICAL" ? 4
        : 0

    readonly property int cardRadius:
        preset === "CAPSULE" ? 12
        : preset === "SOFT" ? 10
        : preset === "HYBRID" ? 6
        : preset === "TECHNICAL" ? 3
        : 0

    readonly property int controlRadius:
        preset === "CAPSULE" || preset === "HYBRID" ? 999
        : preset === "SOFT" ? 8
        : preset === "TECHNICAL" ? 3
        : 0

    readonly property int moduleRadius:
        preset === "CAPSULE" ? Math.round(settings.barHeight / 2)
        : preset === "SOFT" ? 12
        : preset === "HYBRID" ? 6
        : preset === "TECHNICAL" ? 4
        : 0

    readonly property int workspaceRadius:
        settings.workspaceStyle === "PILLS" || settings.workspaceStyle === "DOTS"
            ? 999
            : controlRadius

    readonly property int microRadius:
        preset === "CAPSULE" || preset === "HYBRID" ? 999
        : preset === "SOFT" ? 3
        : 0

    readonly property int borderWidth: settings.borderThickness
    readonly property real fontScale: settings.fontScale
    readonly property real iconScale: settings.iconScale
    readonly property int panelPadding: settings.panelPadding

    // Bar geometry. Every dimension is derived from the same height and density
    // inputs so changing a preset cannot leave mismatched fixed-size children.
    readonly property int identityWidth: Math.round(clamp(
        settings.barHeight * (2.18 + 0.18 * fontScale),
        142,
        212
    ))
    readonly property int identityHoverWidth: identityWidth + Math.round(
        clamp(settings.barHeight * 0.34, 18, 30)
    )
    readonly property int identityHorizontalPadding: Math.round(clamp(
        settings.barHeight * 0.19,
        10,
        16
    ))

    readonly property real workspaceCompression:
        settings.workspaceCount >= 9 ? 0.76
        : settings.workspaceCount >= 7 ? 0.86
        : 1.0
    readonly property int workspaceGap: Math.round(clamp(
        settings.moduleGap * 0.72,
        3,
        8
    ))
    readonly property int workspaceRailPadding: Math.round(clamp(
        settings.barHeight * 0.12,
        7,
        12
    ))
    readonly property int workspaceButtonWidth:
        settings.workspaceStyle === "DOTS"
            ? Math.round(clamp(settings.barHeight * 0.22 * workspaceCompression, 11, 16))
            : Math.round(clamp(settings.barHeight * 0.55 * workspaceCompression, 27, 40))
    readonly property int workspaceHoverWidth:
        settings.workspaceStyle === "DOTS"
            ? Math.round(clamp(settings.barHeight * 0.28 * workspaceCompression, 14, 20))
            : Math.round(clamp(settings.barHeight * 0.66 * workspaceCompression, 32, 46))
    readonly property int workspaceActiveWidth:
        settings.workspaceStyle === "DOTS"
            ? Math.round(clamp(settings.barHeight * 0.35 * workspaceCompression, 18, 24))
            : Math.round(clamp(settings.barHeight * 0.78 * workspaceCompression, 38, 54))
    readonly property int workspaceButtonHeight:
        settings.workspaceStyle === "DOTS"
            ? workspaceButtonWidth
            : Math.round(clamp(settings.barHeight * 0.60, 32, 44))
    readonly property int workspaceActiveHeight:
        settings.workspaceStyle === "DOTS"
            ? workspaceActiveWidth
            : Math.round(clamp(settings.barHeight * 0.82, 42, 58))
    readonly property int workspaceSlotWidth: Math.max(
        workspaceActiveWidth,
        workspaceHoverWidth
    )

    readonly property int mediaHorizontalPadding: Math.round(clamp(
        settings.barHeight * 0.20,
        10,
        16
    ))
    readonly property int mediaContentGap: Math.round(clamp(
        settings.moduleGap * 1.20,
        7,
        14
    ))
    readonly property int albumArtSize: Math.round(clamp(
        (settings.barHeight - 20) * densityScale,
        32,
        50
    ))
    readonly property int spectrumWidth: Math.round(clamp(
        settings.mediaModuleWidth * (
            settings.density === "COMPACT" ? 0.25
            : settings.density === "SPACIOUS" ? 0.34
            : 0.30
        ),
        126,
        238
    ))
    readonly property int spectrumHeight: Math.round(clamp(
        settings.barHeight * 0.58,
        30,
        46
    ))
    readonly property int spectrumGap:
        settings.density === "COMPACT" ? 2 : 3

    // The media progress rail stays flush for the angular presets, but moves
    // inside rounded modules so it follows their silhouette instead of cutting
    // through the curved lower corners.
    readonly property int mediaProgressHeight: 4
    readonly property int mediaProgressHorizontalInset:
        preset === "CAPSULE"
            ? Math.round(clamp(settings.barHeight * 0.20, 12, 18))
        : preset === "SOFT"
            ? Math.round(clamp(settings.barHeight * 0.14, 8, 13))
        : preset === "HYBRID"
            ? Math.round(clamp(settings.barHeight * 0.10, 6, 10))
        : 0
    readonly property int mediaProgressBottomInset:
        preset === "CAPSULE"
            ? Math.round(clamp(settings.barHeight * 0.10, 5, 8))
        : preset === "SOFT" ? 5
        : preset === "HYBRID" ? 4
        : 0
    readonly property int mediaProgressRadius:
        mediaProgressHorizontalInset > 0
            ? Math.ceil(mediaProgressHeight / 2)
            : 0

    readonly property int utilityWidth: Math.round(clamp(
        settings.barHeight * 0.78,
        44,
        58
    ))
    readonly property int utilityHoverWidth: utilityWidth + Math.round(clamp(
        settings.barHeight * 0.78,
        42,
        58
    ))
    readonly property int clockWidth: Math.round(clamp(
        settings.barHeight * (2.14 + 0.12 * fontScale),
        138,
        184
    ))
    readonly property int clockHorizontalPadding: Math.round(clamp(
        settings.barHeight * 0.18,
        10,
        15
    ))
    readonly property int clockSignalHeight: Math.round(clamp(
        settings.barHeight * 0.56,
        30,
        42
    ))

    readonly property int hyprlandRounding: windowRadius
}

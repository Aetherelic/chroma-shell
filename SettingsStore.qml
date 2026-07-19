import QtQuick
import Quickshell
import Quickshell.Io

Scope {
    id: store

    required property var shell

    property bool ready: false

    // Bar composition
    property bool showWorkspaces: true
    property bool showMedia: true
    property bool showAlbumArt: true
    property bool showSpectrum: true
    property bool showNotifications: true
    property bool showThemes: true
    property bool showControl: true
    property bool showClock: true
    property bool showDate: true
    property bool showOsd: true
    property bool showNotificationToasts: true

    // Layout and behaviour
    property int workspaceCount: 6
    property string density: "BALANCED"
    property string barMonitor: "DP-1"
    property string barPosition: "BOTTOM"
    property string animationSpeed: "BALANCED"
    property string clockFormat: "24H"
    property string dateFormat: "SHORT"

    // CHROMA/04 Style Studio
    property string stylePreset: "SHARP"
    property string colorTreatment: "FULL PALETTE"
    property string barBackgroundMode: "TRANSPARENT"
    property string workspaceStyle: "BLOCKS"
    property int barHeight: 73
    property int outerMargin: 14
    property int moduleGap: 8
    property int mediaModuleWidth: 600
    property int borderThickness: 1
    property real fontScale: 1.0
    property real iconScale: 1.0
    property int panelPadding: 18

    // Media / CAVA
    property int spectrumBars: 28
    property real spectrumSensitivity: 1.0
    property real spectrumSmoothing: 0.28
    property string spectrumMode: "THEME"

    // Launcher, notifications and OSD
    property int notificationTimeout: 6
    property int launcherResults: 6
    property bool clipboardPrivate: false
    property int clipboardLimit: 60
    property string osdPosition: "BOTTOM"
    property real osdDuration: 1.45

    // Preferred apps
    property string preferredTerminal: "kitty"
    property string preferredBrowser: "chromium"
    property string preferredFiles: "thunar"
    property string preferredEditor: "code"
    property string preferredTerminalId: ""
    property string preferredBrowserId: ""
    property string preferredFilesId: ""
    property string preferredEditorId: ""
    property var favoriteApplications: []
    property var hiddenApplications: []

    readonly property string configHome:
        Quickshell.env("XDG_CONFIG_HOME").length > 0
            ? Quickshell.env("XDG_CONFIG_HOME")
            : Quickshell.env("HOME") + "/.config"

    readonly property string settingsPath:
        configHome + "/chroma/settings.json"

    readonly property string backendPath:
        Quickshell.shellPath("backend/chroma-settingsctl")

    FileView {
        id: settingsFile
        path: store.settingsPath
        blockLoading: true
        atomicWrites: true
        printErrors: true
    }

    FileView {
        id: legacyFile
        path: Quickshell.statePath("settings-ui.json")
        blockLoading: true
        atomicWrites: false
        printErrors: false
    }

    Timer {
        id: saveTimer
        interval: 140
        repeat: false
        onTriggered: store.save()
    }

    Timer {
        id: styleSyncTimer
        interval: 180
        repeat: false
        onTriggered: store.syncHyprlandStyle()
    }

    onStylePresetChanged: {
        if (ready) {
            styleSyncTimer.restart()
        }
    }

    onBorderThicknessChanged: {
        if (ready) {
            styleSyncTimer.restart()
        }
    }

    function clamp(value, minimum, maximum) {
        return Math.max(minimum, Math.min(maximum, Number(value)))
    }

    function normaliseChoice(value, choices, fallback) {
        var candidate = String(value || "").toUpperCase()
        return choices.indexOf(candidate) >= 0 ? candidate : fallback
    }

    function normaliseStringList(value, maximum) {
        var result = []
        var limit = Math.max(0, Number(maximum || 64))

        if (!value || value.length === undefined) {
            return result
        }

        for (var index = 0; index < value.length && result.length < limit; index++) {
            var candidate = String(value[index] || "").trim()
            if (candidate.length > 0 && result.indexOf(candidate) < 0) {
                result.push(candidate)
            }
        }

        return result
    }

    function styleProfile(preset) {
        var name = normaliseChoice(
            preset,
            ["SHARP", "TECHNICAL", "SOFT", "CAPSULE", "HYBRID"],
            "SHARP"
        )

        if (name === "TECHNICAL") {
            return {
                preset: name, barHeight: 66, outerMargin: 8, moduleGap: 6,
                mediaWidth: 560, borderThickness: 1, fontScale: 0.95,
                iconScale: 0.95, panelPadding: 16, workspaceStyle: "BLOCKS"
            }
        }

        if (name === "SOFT") {
            return {
                preset: name, barHeight: 68, outerMargin: 10, moduleGap: 8,
                mediaWidth: 560, borderThickness: 2, fontScale: 1.0,
                iconScale: 1.0, panelPadding: 18, workspaceStyle: "BLOCKS"
            }
        }

        if (name === "CAPSULE") {
            return {
                preset: name, barHeight: 64, outerMargin: 10, moduleGap: 8,
                mediaWidth: 540, borderThickness: 2, fontScale: 0.95,
                iconScale: 0.92, panelPadding: 18, workspaceStyle: "PILLS"
            }
        }

        if (name === "HYBRID") {
            return {
                preset: name, barHeight: 66, outerMargin: 8, moduleGap: 7,
                mediaWidth: 560, borderThickness: 1, fontScale: 1.0,
                iconScale: 0.95, panelPadding: 17, workspaceStyle: "PILLS"
            }
        }

        return {
            preset: "SHARP", barHeight: 64, outerMargin: 8, moduleGap: 6,
            mediaWidth: 560, borderThickness: 1, fontScale: 1.0,
            iconScale: 0.95, panelPadding: 16, workspaceStyle: "BLOCKS"
        }
    }

    function applyStyleProfile(preset) {
        var profile = styleProfile(preset)

        stylePreset = profile.preset
        barHeight = profile.barHeight
        outerMargin = profile.outerMargin
        moduleGap = profile.moduleGap
        mediaModuleWidth = profile.mediaWidth
        borderThickness = profile.borderThickness
        fontScale = profile.fontScale
        iconScale = profile.iconScale
        panelPadding = profile.panelPadding
        workspaceStyle = profile.workspaceStyle
    }

    function selectStylePreset(preset) {
        applyStyleProfile(preset)
        scheduleSave()
        styleSyncTimer.restart()
    }

    function syncHyprlandStyle() {
        Quickshell.execDetached([
            "bash",
            backendPath,
            "style-sync",
            stylePreset,
            String(borderThickness)
        ])
    }

    function scheduleSave() {
        if (ready) {
            saveTimer.restart()
        }
    }

    function save() {
        if (!ready) {
            return
        }

        settingsFile.setText(JSON.stringify({
            version: 7,
            widgets: {
                workspaces: showWorkspaces,
                media: showMedia,
                albumArt: showAlbumArt,
                spectrum: showSpectrum,
                notifications: showNotifications,
                themes: showThemes,
                control: showControl,
                clock: showClock,
                date: showDate,
                osd: showOsd,
                notificationToasts: showNotificationToasts
            },
            layout: {
                workspaceCount: workspaceCount,
                density: density,
                barMonitor: barMonitor,
                barPosition: barPosition,
                animationSpeed: animationSpeed,
                clockFormat: clockFormat,
                dateFormat: dateFormat
            },
            style: {
                preset: stylePreset,
                colorTreatment: colorTreatment,
                barBackgroundMode: barBackgroundMode,
                workspaceStyle: workspaceStyle,
                barHeight: barHeight,
                outerMargin: outerMargin,
                moduleGap: moduleGap,
                mediaWidth: mediaModuleWidth,
                borderThickness: borderThickness,
                fontScale: fontScale,
                iconScale: iconScale,
                panelPadding: panelPadding
            },
            spectrum: {
                bars: spectrumBars,
                sensitivity: spectrumSensitivity,
                smoothing: spectrumSmoothing,
                mode: spectrumMode
            },
            notifications: {
                timeout: notificationTimeout
            },
            launcher: {
                results: launcherResults
            },
            clipboard: {
                privateMode: clipboardPrivate,
                limit: clipboardLimit
            },
            osd: {
                position: osdPosition,
                duration: osdDuration
            },
            applications: {
                terminal: preferredTerminal,
                browser: preferredBrowser,
                files: preferredFiles,
                editor: preferredEditor,
                terminalId: preferredTerminalId,
                browserId: preferredBrowserId,
                filesId: preferredFilesId,
                editorId: preferredEditorId,
                favorites: favoriteApplications,
                hidden: hiddenApplications
            }
        }, null, 2) + "\n")
    }

    function resetDefaults() {
        showWorkspaces = true
        showMedia = true
        showAlbumArt = true
        showSpectrum = true
        showNotifications = true
        showThemes = true
        showControl = true
        showClock = true
        showDate = true
        showOsd = true
        showNotificationToasts = true

        workspaceCount = 6
        density = "BALANCED"
        barMonitor = "DP-1"
        barPosition = "BOTTOM"
        animationSpeed = "BALANCED"
        clockFormat = "24H"
        dateFormat = "SHORT"

        applyStyleProfile("SHARP")
        colorTreatment = "FULL PALETTE"
        barBackgroundMode = "TRANSPARENT"

        spectrumBars = 28
        spectrumSensitivity = 1.0
        spectrumSmoothing = 0.28
        spectrumMode = "THEME"

        notificationTimeout = 6
        launcherResults = 6
        clipboardPrivate = false
        clipboardLimit = 60
        osdPosition = "BOTTOM"
        osdDuration = 1.45

        preferredTerminal = "kitty"
        preferredBrowser = "chromium"
        preferredFiles = "thunar"
        preferredEditor = "code"
        preferredTerminalId = ""
        preferredBrowserId = ""
        preferredFilesId = ""
        preferredEditorId = ""
        favoriteApplications = []
        hiddenApplications = []

        scheduleSave()
    }

    Component.onCompleted: {
        var data = ({})
        var loadedVersion = 0
        var raw = settingsFile.text()

        if (!raw || raw.trim().length === 0) {
            raw = legacyFile.text()
        }

        if (raw && raw.trim().length > 0) {
            try {
                data = JSON.parse(raw)
            } catch (error) {
                console.warn("CHROMA settings were invalid; defaults restored")
            }
        }

        loadedVersion = Number(data.version || 0)

        var widgets = data.widgets || ({})
        var layout = data.layout || data
        var style = data.style || ({})
        var spectrum = data.spectrum || ({})
        var notifications = data.notifications || ({})
        var launcher = data.launcher || ({})
        var clipboard = data.clipboard || ({})
        var osd = data.osd || ({})
        var apps = data.applications || ({})

        showWorkspaces = widgets.workspaces !== false
        showMedia = widgets.media !== false
        showAlbumArt = widgets.albumArt !== false
        showSpectrum = widgets.spectrum !== false
        showNotifications = widgets.notifications !== false
        showThemes = widgets.themes !== false
        showControl = widgets.control !== false
        showClock = widgets.clock !== false
        showDate = widgets.date !== false
        showOsd = widgets.osd !== false
        showNotificationToasts = widgets.notificationToasts !== false

        workspaceCount = Math.round(clamp(layout.workspaceCount || 6, 1, 10))
        density = normaliseChoice(
            layout.density,
            ["COMPACT", "BALANCED", "SPACIOUS"],
            "BALANCED"
        )
        barMonitor = String(layout.barMonitor || "DP-1")
        barPosition = normaliseChoice(
            layout.barPosition,
            ["TOP", "BOTTOM"],
            "BOTTOM"
        )
        animationSpeed = normaliseChoice(
            layout.animationSpeed,
            ["FAST", "BALANCED", "CINEMATIC"],
            "BALANCED"
        )
        clockFormat = normaliseChoice(
            layout.clockFormat,
            ["12H", "24H"],
            "24H"
        )
        dateFormat = normaliseChoice(
            layout.dateFormat,
            ["SHORT", "ISO", "VERBOSE"],
            "SHORT"
        )

        stylePreset = normaliseChoice(
            style.preset,
            ["SHARP", "TECHNICAL", "SOFT", "CAPSULE", "HYBRID"],
            "SHARP"
        )
        colorTreatment = normaliseChoice(
            style.colorTreatment,
            ["FULL PALETTE", "ACCENT ONLY", "DUOTONE", "MONOCHROME", "SPECTRUM", "MUTED"],
            "FULL PALETTE"
        )
        barBackgroundMode = normaliseChoice(
            style.barBackgroundMode,
            ["TRANSPARENT", "SOLID"],
            "TRANSPARENT"
        )
        workspaceStyle = normaliseChoice(
            style.workspaceStyle,
            ["BLOCKS", "PILLS", "DOTS"],
            "BLOCKS"
        )
        barHeight = Math.round(clamp(style.barHeight || 73, 56, 92))
        outerMargin = Math.round(clamp(
            style.outerMargin !== undefined ? style.outerMargin : 14,
            0,
            28
        ))
        moduleGap = Math.round(clamp(style.moduleGap || 8, 2, 18))
        mediaModuleWidth = Math.round(clamp(style.mediaWidth || 600, 420, 760))
        borderThickness = Math.round(clamp(
            style.borderThickness !== undefined ? style.borderThickness : 1,
            0,
            3
        ))
        fontScale = clamp(style.fontScale || 1.0, 0.85, 1.25)
        iconScale = clamp(style.iconScale || 1.0, 0.80, 1.30)
        panelPadding = Math.round(clamp(style.panelPadding || 18, 10, 30))

        // CHROMA/04 geometry profiles became complete in schema v4.
        // Migrate earlier radius-only presets once so existing users do not
        // keep the mismatched dimensions that prompted this fix.
        if (loadedVersion < 4) {
            applyStyleProfile(stylePreset)
        }

        spectrumBars = Math.round(clamp(spectrum.bars || 28, 12, 40))
        spectrumSensitivity = clamp(spectrum.sensitivity || 1.0, 0.5, 2.0)
        spectrumSmoothing = clamp(
            spectrum.smoothing !== undefined ? spectrum.smoothing : 0.28,
            0.05,
            0.85
        )
        spectrumMode = normaliseChoice(
            spectrum.mode,
            ["THEME", "ACCENT", "DUOTONE", "RAINBOW", "FREQUENCY", "MONOCHROME"],
            "THEME"
        )

        notificationTimeout = Math.round(clamp(
            notifications.timeout || data.notificationTimeout || 6,
            2,
            20
        ))
        launcherResults = Math.round(clamp(
            launcher.results || data.launcherResults || 6,
            3,
            10
        ))
        clipboardPrivate = clipboard.privateMode === true
        clipboardLimit = Math.round(clamp(clipboard.limit || 60, 20, 200))
        osdPosition = normaliseChoice(
            osd.position,
            ["TOP", "BOTTOM"],
            "BOTTOM"
        )
        osdDuration = clamp(osd.duration || 1.45, 0.6, 4.0)

        preferredTerminal = apps.terminal || "kitty"
        preferredBrowser = apps.browser || "chromium"
        preferredFiles = apps.files || "thunar"
        preferredEditor = apps.editor || "code"
        preferredTerminalId = String(apps.terminalId || "")
        preferredBrowserId = String(apps.browserId || "")
        preferredFilesId = String(apps.filesId || "")
        preferredEditorId = String(apps.editorId || "")
        favoriteApplications = normaliseStringList(apps.favorites, 12)
        hiddenApplications = normaliseStringList(apps.hidden, 128)

        ready = true
        saveTimer.restart()
        styleSyncTimer.restart()
    }
}

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Services.Mpris
import "desktop"

ShellRoot {
    id: root

    property date now: new Date()
    property int tick: 0
    property bool drawerOpen: false
    property bool launcherOpen: false
    property bool clipboardOpen: false
    property bool controlCenterOpen: false
    property bool notificationCenterOpen: false
    property bool themePanelOpen: false
    property bool settingsOpen: false
    readonly property var widgetManager: widgetStore
    readonly property var systemStats: widgetStats
    property bool doNotDisturb: false

    property string themeName: "VOLTAGE"
    property int themeIndex: 0

    readonly property int notificationCount:
        notificationCentre.notificationCount

    readonly property int themeCount:
        stateStore.themes.length

    readonly property bool showWorkspaces: settingsStore.showWorkspaces
    readonly property bool showMedia: settingsStore.showMedia
    readonly property bool showAlbumArt: settingsStore.showAlbumArt
    readonly property bool showSpectrum: settingsStore.showSpectrum
    readonly property bool showNotifications: settingsStore.showNotifications
    readonly property bool showThemes: settingsStore.showThemes
    readonly property bool showControl: settingsStore.showControl
    readonly property bool showClock: settingsStore.showClock
    readonly property bool showDate: settingsStore.showDate
    readonly property bool showOsd: settingsStore.showOsd
    readonly property bool showNotificationToasts: settingsStore.showNotificationToasts

    readonly property int workspaceCount: settingsStore.workspaceCount
    readonly property string density: settingsStore.density
    readonly property string barMonitor: settingsStore.barMonitor
    readonly property string barPosition: settingsStore.barPosition
    readonly property string animationSpeed: settingsStore.animationSpeed
    readonly property string clockFormat: settingsStore.clockFormat
    readonly property string dateFormat: settingsStore.dateFormat

    readonly property int spectrumBars: settingsStore.spectrumBars
    readonly property real spectrumSensitivity: settingsStore.spectrumSensitivity
    readonly property real spectrumSmoothing: settingsStore.spectrumSmoothing
    readonly property string spectrumMode: settingsStore.spectrumMode

    readonly property int notificationTimeout: settingsStore.notificationTimeout
    readonly property int launcherResults: settingsStore.launcherResults
    readonly property string osdPosition: settingsStore.osdPosition
    readonly property real osdDuration: settingsStore.osdDuration
    readonly property var favoriteApplications: settingsStore.favoriteApplications
    readonly property var hiddenApplications: settingsStore.hiddenApplications

    readonly property string stylePreset: settingsStore.stylePreset
    readonly property string colorTreatment: settingsStore.colorTreatment
    readonly property string workspaceStyle: settingsStore.workspaceStyle
    readonly property int borderWidth: styleTokens.borderWidth
    readonly property int panelRadius: styleTokens.panelRadius
    readonly property int windowRadius: styleTokens.windowRadius
    readonly property int cardRadius: styleTokens.cardRadius
    readonly property int controlRadius: styleTokens.controlRadius
    readonly property int moduleRadius: styleTokens.moduleRadius
    readonly property int workspaceRadius: styleTokens.workspaceRadius
    readonly property int microRadius: styleTokens.microRadius
    readonly property real fontScale: styleTokens.fontScale
    readonly property real iconScale: styleTokens.iconScale
    readonly property int panelPadding: styleTokens.panelPadding
    readonly property int identityWidth: styleTokens.identityWidth
    readonly property int identityHoverWidth: styleTokens.identityHoverWidth
    readonly property int identityHorizontalPadding:
        styleTokens.identityHorizontalPadding
    readonly property int workspaceGap: styleTokens.workspaceGap
    readonly property int workspaceRailPadding:
        styleTokens.workspaceRailPadding
    readonly property int workspaceButtonWidth:
        styleTokens.workspaceButtonWidth
    readonly property int workspaceHoverWidth:
        styleTokens.workspaceHoverWidth
    readonly property int workspaceActiveWidth:
        styleTokens.workspaceActiveWidth
    readonly property int workspaceButtonHeight:
        styleTokens.workspaceButtonHeight
    readonly property int workspaceActiveHeight:
        styleTokens.workspaceActiveHeight
    readonly property int workspaceSlotWidth:
        styleTokens.workspaceSlotWidth
    readonly property int mediaHorizontalPadding:
        styleTokens.mediaHorizontalPadding
    readonly property int mediaContentGap: styleTokens.mediaContentGap
    readonly property int albumArtSize: styleTokens.albumArtSize
    readonly property int spectrumWidth: styleTokens.spectrumWidth
    readonly property int spectrumHeight: styleTokens.spectrumHeight
    readonly property int spectrumGap: styleTokens.spectrumGap
    readonly property int mediaProgressHeight:
        styleTokens.mediaProgressHeight
    readonly property int mediaProgressHorizontalInset:
        styleTokens.mediaProgressHorizontalInset
    readonly property int mediaProgressBottomInset:
        styleTokens.mediaProgressBottomInset
    readonly property int mediaProgressRadius:
        styleTokens.mediaProgressRadius
    readonly property int utilityWidth: styleTokens.utilityWidth
    readonly property int utilityHoverWidth: styleTokens.utilityHoverWidth
    readonly property int clockWidth: styleTokens.clockWidth
    readonly property int clockHorizontalPadding:
        styleTokens.clockHorizontalPadding
    readonly property int clockSignalHeight:
        styleTokens.clockSignalHeight

    readonly property int animationDuration:
        animationSpeed === "FAST"
            ? 90
            : animationSpeed === "CINEMATIC"
                ? 240
                : 150

    readonly property int barHeight: settingsStore.barHeight

    readonly property int barOuterMargin: settingsStore.outerMargin

    readonly property int barGap: settingsStore.moduleGap

    readonly property int mediaWidth: settingsStore.mediaModuleWidth

    readonly property int workspaceRailWidth:
        workspaceCount <= 0
            ? 0
            : workspaceRailPadding * 2
                + workspaceSlotWidth * workspaceCount
                + workspaceGap * Math.max(0, workspaceCount - 1)

    readonly property string resolvedBarMonitor: {
        var screens = Quickshell.screens
        for (var index = 0; index < screens.length; index++) {
            if (screens[index].name === barMonitor) {
                return barMonitor
            }
        }
        return screens.length > 0 ? screens[0].name : barMonitor
    }

    readonly property string datePattern:
        dateFormat === "ISO"
            ? "yyyy-MM-dd"
            : dateFormat === "VERBOSE"
                ? "dddd  dd MMMM"
                : "ddd  dd.MM.yy"

    readonly property var uiPalette:
        colorTreatment === "ACCENT ONLY"
            ? [palette[4], palette[4], warning, success, palette[4], palette[4], palette[4]]
            : colorTreatment === "DUOTONE"
                ? [palette[0], palette[4], palette[0], palette[4], palette[0], palette[4], palette[0]]
                : colorTreatment === "MONOCHROME"
                    ? [text, muted, dim, textStrong, borderStrong, muted, text]
                    : colorTreatment === "MUTED"
                        ? [muted, dim, warning, success, palette[4], palette[5], muted]
                        : palette

    readonly property var visualizerPalette:
        spectrumMode === "RAINBOW"
            ? [
                "#ff4f79", "#ff9f43", "#ffe66d", "#45f0a8",
                "#42c8ff", "#8f7cff", "#db5cff"
            ]
            : spectrumMode === "ACCENT"
                ? [uiPalette[4], uiPalette[4], uiPalette[5], uiPalette[4]]
                : spectrumMode === "DUOTONE"
                    ? [uiPalette[0], uiPalette[4], uiPalette[0], uiPalette[4]]
                    : spectrumMode === "MONOCHROME"
                        ? [muted, text, textStrong, muted]
                        : spectrumMode === "FREQUENCY"
                            ? [success, palette[4], palette[5], warning, error]
                            : spectrumPalette


    function themeAt(index) {
        return stateStore.themes[index]
    }

    function applyTheme(index) {
        stateStore.applyTheme(index, true)
    }

    function cycleTheme(step) {
        stateStore.cycleTheme(step)
    }

    function screenFor(name) {
        var screens = Quickshell.screens
        for (var index = 0; index < screens.length; index++) {
            if (screens[index].name === name) {
                return screens[index]
            }
        }
        return screens.length > 0 ? screens[0] : null
    }

    onLauncherOpenChanged: {
        if (launcherOpen) {
            clipboardOpen = false
            controlCenterOpen = false
            notificationCenterOpen = false
            themePanelOpen = false
            settingsOpen = false
        }
    }

    onClipboardOpenChanged: {
        if (clipboardOpen) {
            launcherOpen = false
            drawerOpen = false
            controlCenterOpen = false
            notificationCenterOpen = false
            themePanelOpen = false
            settingsOpen = false
        }
    }

    onControlCenterOpenChanged: {
        if (controlCenterOpen) {
            launcherOpen = false
            clipboardOpen = false
            drawerOpen = false
            notificationCenterOpen = false
            themePanelOpen = false
            settingsOpen = false
        }
    }

    onDrawerOpenChanged: {
        if (drawerOpen) {
            clipboardOpen = false
            controlCenterOpen = false
            notificationCenterOpen = false
            themePanelOpen = false
            settingsOpen = false
        }
    }

    onNotificationCenterOpenChanged: {
        if (notificationCenterOpen) {
            launcherOpen = false
            clipboardOpen = false
            controlCenterOpen = false
            drawerOpen = false
            themePanelOpen = false
            settingsOpen = false
        }
    }

    onThemePanelOpenChanged: {
        if (themePanelOpen) {
            launcherOpen = false
            clipboardOpen = false
            controlCenterOpen = false
            drawerOpen = false
            notificationCenterOpen = false
            settingsOpen = false
        }
    }

    onSettingsOpenChanged: {
        if (settingsOpen) {
            launcherOpen = false
            clipboardOpen = false
            controlCenterOpen = false
            drawerOpen = false
            notificationCenterOpen = false
            themePanelOpen = false
        }
    }

    // Theme roles are applied centrally by StateStore. Every CHROMA
    // surface consumes these properties, so a palette change recolours
    // the complete shell rather than only its accent widgets.
    property color ink: "#090a10"
    property color background: "#090b12"
    property color backgroundAlt: "#0b0d14"
    property color surface: "#11141d"
    property color surfaceAlt: "#1a1e29"
    property color surfaceHover: "#252a38"
    property color border: "#303442"
    property color borderStrong: "#353949"
    property color text: "#f2f2f7"
    property color textStrong: "#f4f4fa"
    property color muted: "#777e92"
    property color dim: "#62697b"
    property color success: "#45f0a8"
    property color warning: "#ffe66d"
    property color error: "#ff4f79"

    property var palette: [
        "#ff4f79", "#ff9f43", "#ffe66d", "#45f0a8",
        "#42c8ff", "#8f7cff", "#db5cff"
    ]

    property var spectrumPalette: [
        "#45f0a8", "#42c8ff", "#8f7cff", "#db5cff",
        "#ff4f79", "#ff9f43", "#ffe66d"
    ]

    property var player: {
        var players = Mpris.players.values

        for (var index = 0; index < players.length; index++) {
            if (players[index] && players[index].isPlaying) {
                return players[index]
            }
        }

        return players.length > 0 ? players[0] : null
    }

    property bool hasMedia:
        player !== null
        && (
            (player.trackTitle || "").length > 0
            || (player.identity || "").length > 0
        )

    property bool mediaPlaying:
        player !== null && player.isPlaying

    property string activeTitle:
        Hyprland.activeToplevel !== null
        && (Hyprland.activeToplevel.title || "").length > 0
            ? Hyprland.activeToplevel.title
            : "DESKTOP // IDLE"

    property string contextTitle:
        hasMedia
            ? (player.trackTitle || "UNTITLED SIGNAL")
            : activeTitle

    property string contextSubtitle:
        hasMedia
            ? (
                player.trackArtist
                || player.trackAlbum
                || player.identity
                || "UNKNOWN ARTIST"
            )
            : "ACTIVE WINDOW CHANNEL"

    property color contextAccent:
        hasMedia
            ? uiPalette[6]
            : uiPalette[4]

    property real mediaProgress:
        player !== null
        && player.length > 0
            ? Math.max(
                0,
                Math.min(1, player.position / player.length)
            )
            : 0

    readonly property var spectrumValues:
        audioSpectrum.values

    readonly property bool spectrumAvailable:
        audioSpectrum.available

    function formatSeconds(seconds) {
        if (!seconds || seconds < 0) {
            return "00:00"
        }

        var total = Math.floor(seconds)
        var minutes = Math.floor(total / 60)
        var remaining = total % 60

        return (
            (minutes < 10 ? "0" : "")
            + minutes
            + ":"
            + (remaining < 10 ? "0" : "")
            + remaining
        )
    }

    function workspaceFor(number) {
        var workspaces = Hyprland.workspaces.values

        for (var index = 0; index < workspaces.length; index++) {
            if (workspaces[index].id === number) {
                return workspaces[index]
            }
        }

        return null
    }

    Timer {
        interval: 1000
        running: true
        repeat: true

        onTriggered: {
            root.now = new Date()

            if (
                root.player !== null
                && root.player.isPlaying
                && root.player.positionSupported
            ) {
                root.player.positionChanged()
            }
        }
    }

    Timer {
        interval: 110
        running: true
        repeat: true

        onTriggered:
            root.tick = (root.tick + 1) % 100000
    }

    AudioSpectrum {
        id: audioSpectrum
        enabled:
            (root.hasMedia && root.showSpectrum)
            || (widgetStore.ready && widgetStore.hasActiveType("cava"))
        barCount: root.spectrumBars
        sensitivity: root.spectrumSensitivity
        smoothing: root.spectrumSmoothing
    }

    StateStore {
        id: stateStore
        shell: root
    }

    SettingsStore {
        id: settingsStore
        shell: root
    }

    WidgetStore {
        id: widgetStore
        shell: root
    }

    SystemStats {
        id: widgetStats
        enabled: widgetStore.ready && widgetStore.hasActiveType("system")
    }

    StyleTokens {
        id: styleTokens
        settings: settingsStore
    }

    Connections {
        target: settingsStore

        function onShowMediaChanged() {
            if (!settingsStore.showMedia) {
                root.drawerOpen = false
            }
        }

        function onShowNotificationsChanged() {
            if (!settingsStore.showNotifications) {
                root.notificationCenterOpen = false
            }
        }

        function onShowThemesChanged() {
            if (!settingsStore.showThemes) {
                root.themePanelOpen = false
            }
        }

        function onShowControlChanged() {
            if (!settingsStore.showControl) {
                root.controlCenterOpen = false
            }
        }
    }

    ContextDrawer {
        shell: root
    }

    ChromaBar {
        shell: root
    }

    DesktopWidgets {
        shell: root
        store: widgetStore
    }

    ChromaLauncher {
        shell: root
    }

    ClipboardPanel {
        id: clipboardPanel
        shell: root
        settings: settingsStore
    }

    ControlCentre {
        shell: root
    }

    NotificationCentre {
        id: notificationCentre
        shell: root
    }

    ThemePanel {
        shell: root
    }

    LazyLoader {
        id: settingsWindowLoader
        active: root.settingsOpen

        SettingsWindow {
            shell: root
            settings: settingsStore
        }
    }

    ChromaOsd {
        shell: root
    }

    GlobalShortcut {
        appid: "chroma"
        name: "launcher"
        description: "Toggle the CHROMA application launcher"

        onPressed:
            root.launcherOpen = !root.launcherOpen
    }

    GlobalShortcut {
        appid: "chroma"
        name: "clipboard"
        description: "Toggle the CHROMA clipboard manager"

        onPressed:
            root.clipboardOpen = !root.clipboardOpen
    }

    GlobalShortcut {
        appid: "chroma"
        name: "control-center"
        description: "Toggle the CHROMA control centre"

        onPressed:
            root.controlCenterOpen = !root.controlCenterOpen
    }

    GlobalShortcut {
        appid: "chroma"
        name: "notifications"
        description: "Toggle the CHROMA notification rail"

        onPressed:
            root.notificationCenterOpen = !root.notificationCenterOpen
    }

    GlobalShortcut {
        appid: "chroma"
        name: "themes"
        description: "Toggle the CHROMA theme panel"

        onPressed:
            root.themePanelOpen = !root.themePanelOpen
    }

    GlobalShortcut {
        appid: "chroma"
        name: "settings"
        description: "Toggle the CHROMA settings application"

        onPressed:
            root.settingsOpen = !root.settingsOpen
    }

    IpcHandler {
        target: "chroma"

        function toggleLauncher(): void {
            root.launcherOpen = !root.launcherOpen
        }

        function toggleClipboard(): void {
            root.clipboardOpen = !root.clipboardOpen
        }

        function openClipboard(): void {
            root.clipboardOpen = true
        }

        function closeClipboard(): void {
            root.clipboardOpen = false
        }

        function clearClipboard(): void {
            Quickshell.execDetached([
                "bash",
                Quickshell.shellPath("backend/chroma-clipboardctl"),
                "clear"
            ])
        }

        function setClipboardPrivate(enabled: bool): void {
            settingsStore.clipboardPrivate = enabled
            settingsStore.scheduleSave()
        }

        function toggleControl(): void {
            root.controlCenterOpen = !root.controlCenterOpen
        }

        function toggleNotifications(): void {
            root.notificationCenterOpen = !root.notificationCenterOpen
        }

        function toggleThemes(): void {
            root.themePanelOpen = !root.themePanelOpen
        }

        function toggleSettings(): void {
            root.settingsOpen = !root.settingsOpen
        }

        function toggleWidgetEdit(): void {
            widgetStore.editMode = !widgetStore.editMode
        }

        function openWidgetEdit(): void {
            widgetStore.editMode = true
        }

        function closeWidgetEdit(): void {
            widgetStore.editMode = false
        }

        function addDesktopWidget(type: string): void {
            widgetStore.addWidget(type, widgetStore.activeMonitor)
        }

        function resetDesktopWidgets(): void {
            widgetStore.resetMonitor(widgetStore.activeMonitor)
        }

        function cycleTheme(step: int): void {
            root.cycleTheme(step)
        }

        function setTheme(index: int): void {
            root.applyTheme(index)
        }
    }

}

import QtQuick
import Quickshell
import Quickshell.Io

Scope {
    id: store

    required property var shell

    property bool ready: false
    property bool enabled: true
    property bool editMode: false
    property int snapSize: 16
    property string selectedId: ""
    property string activeMonitor: shell.resolvedBarMonitor
    property var monitorEnabled: ({})
    property var widgets: []

    readonly property string settingsPath:
        Quickshell.env("HOME") + "/.config/chroma/widgets.json"

    FileView {
        id: widgetFile
        path: store.settingsPath
        blockLoading: true
        atomicWrites: true
        printErrors: true
    }

    Timer {
        id: saveTimer
        interval: 120
        repeat: false
        onTriggered: store.save()
    }

    function clamp(value, minimum, maximum) {
        return Math.max(minimum, Math.min(maximum, Number(value)))
    }

    function clone(value) {
        return JSON.parse(JSON.stringify(value))
    }

    function defaultSize(type) {
        switch (String(type).toLowerCase()) {
        case "music": return { width: 520, height: 180 }
        case "cava": return { width: 460, height: 180 }
        case "system": return { width: 360, height: 230 }
        default: return { width: 380, height: 180 }
        }
    }

    function defaultSettings(type) {
        var common = {
            fontFamily: "JetBrainsMono Nerd Font",
            fontScale: 1.0,
            surface: "SOLID"
        }

        switch (String(type).toLowerCase()) {
        case "music":
            common.artwork = true
            common.progress = true
            common.controls = true
            return common
        case "clock":
            common.seconds = false
            common.date = true
            common.layout = "DIGITAL"
            common.surface = "TRANSPARENT"
            return common
        case "system":
            common.cpu = true
            common.gpu = true
            common.memory = true
            common.temperature = true
            return common
        case "cava":
            common.bars = 28
            common.mode = "THEME"
            return common
        default:
            return common
        }
    }

    function mergeSettings(type, candidate) {
        var merged = defaultSettings(type)
        var source = candidate || ({})
        for (var key in source) {
            merged[key] = source[key]
        }
        merged.fontFamily = String(merged.fontFamily || "JetBrainsMono Nerd Font")
        merged.fontScale = clamp(merged.fontScale || 1.0, 0.70, 1.80)
        merged.surface = normaliseSurface(merged.surface)
        return merged
    }

    function normaliseSurface(value) {
        var mode = String(value || "SOLID").toUpperCase()
        return ["SOLID", "TRANSLUCENT", "TRANSPARENT"].indexOf(mode) >= 0
            ? mode
            : "SOLID"
    }

    function defaultWidgets(monitor) {
        var target = String(monitor || shell.resolvedBarMonitor)
        return [
            {
                id: "clock-1",
                type: "clock",
                monitor: target,
                x: 0.035,
                y: 0.055,
                width: 380,
                height: 180,
                locked: false,
                settings: defaultSettings("clock")
            },
            {
                id: "system-1",
                type: "system",
                monitor: target,
                x: 0.965,
                y: 0.055,
                width: 360,
                height: 230,
                locked: false,
                settings: defaultSettings("system")
            },
            {
                id: "music-1",
                type: "music",
                monitor: target,
                x: 0.5,
                y: 0.82,
                width: 520,
                height: 180,
                locked: false,
                settings: defaultSettings("music")
            }
        ]
    }

    function uniqueId(type) {
        var prefix = String(type || "widget").toLowerCase()
        var stamp = Date.now()
        var counter = 1
        var candidate = prefix + "-" + stamp
        while (findWidget(candidate) !== null) {
            candidate = prefix + "-" + stamp + "-" + counter
            counter++
        }
        return candidate
    }

    function normaliseWidget(candidate) {
        var type = String(candidate.type || "clock").toLowerCase()
        var size = defaultSize(type)
        return {
            id: String(candidate.id || uniqueId(type)),
            type: ["music", "clock", "system", "cava"].indexOf(type) >= 0
                ? type
                : "clock",
            monitor: String(candidate.monitor || shell.resolvedBarMonitor),
            x: clamp(candidate.x !== undefined ? candidate.x : 0.05, 0, 1),
            y: clamp(candidate.y !== undefined ? candidate.y : 0.05, 0, 1),
            width: Math.round(clamp(candidate.width || size.width, 220, 900)),
            height: Math.round(clamp(candidate.height || size.height, 120, 600)),
            locked: candidate.locked === true,
            settings: mergeSettings(type, candidate.settings)
        }
    }

    function widgetsForMonitor(name) {
        var result = []
        for (var index = 0; index < widgets.length; index++) {
            if (widgets[index].monitor === name) {
                result.push(widgets[index])
            }
        }
        return result
    }

    function isMonitorEnabled(name) {
        return monitorEnabled[name] !== false
    }

    function setMonitorEnabled(name, value) {
        var next = clone(monitorEnabled)
        next[name] = value === true
        monitorEnabled = next
        scheduleSave()
    }

    function findWidget(id) {
        for (var index = 0; index < widgets.length; index++) {
            if (widgets[index].id === id) {
                return widgets[index]
            }
        }
        return null
    }

    function selectedWidget() {
        return findWidget(selectedId)
    }

    function hasType(type) {
        for (var index = 0; index < widgets.length; index++) {
            if (widgets[index].type === type) {
                return true
            }
        }
        return false
    }

    function hasActiveType(type) {
        if (!enabled) {
            return false
        }
        for (var index = 0; index < widgets.length; index++) {
            if (
                widgets[index].type === type
                && isMonitorEnabled(widgets[index].monitor)
            ) {
                return true
            }
        }
        return false
    }

    function addWidget(type, monitor) {
        var name = String(monitor || activeMonitor || shell.resolvedBarMonitor)
        var size = defaultSize(type)
        var count = widgetsForMonitor(name).length
        var next = widgets.slice()
        var widget = normaliseWidget({
            id: uniqueId(type),
            type: type,
            monitor: name,
            x: clamp(0.08 + (count % 4) * 0.08, 0, 0.82),
            y: clamp(0.12 + (count % 5) * 0.10, 0, 0.78),
            width: size.width,
            height: size.height,
            settings: defaultSettings(type)
        })
        next.push(widget)
        widgets = next
        selectedId = widget.id
        scheduleSave()
    }

    function duplicateWidget(id) {
        var source = findWidget(id)
        if (source === null) {
            return
        }
        var copy = clone(source)
        copy.id = uniqueId(copy.type)
        copy.x = clamp(copy.x + 0.04, 0, 1)
        copy.y = clamp(copy.y + 0.04, 0, 1)
        var next = widgets.slice()
        next.push(normaliseWidget(copy))
        widgets = next
        selectedId = copy.id
        scheduleSave()
    }

    function removeWidget(id) {
        var next = []
        for (var index = 0; index < widgets.length; index++) {
            if (widgets[index].id !== id) {
                next.push(widgets[index])
            }
        }
        widgets = next
        if (selectedId === id) {
            selectedId = ""
        }
        scheduleSave()
    }

    function updateWidget(id, changes) {
        var next = []
        for (var index = 0; index < widgets.length; index++) {
            var entry = widgets[index]
            if (entry.id === id) {
                var updated = clone(entry)
                for (var key in changes) {
                    updated[key] = changes[key]
                }
                entry = normaliseWidget(updated)
            }
            next.push(entry)
        }
        widgets = next
        scheduleSave()
    }

    function updateGeometry(id, x, y, width, height) {
        updateWidget(id, {
            x: clamp(x, 0, 1),
            y: clamp(y, 0, 1),
            width: Math.round(clamp(width, 220, 900)),
            height: Math.round(clamp(height, 120, 600))
        })
    }

    function setLocked(id, value) {
        updateWidget(id, { locked: value === true })
    }

    function updateWidgetSettings(id, changes) {
        var entry = findWidget(id)
        if (entry === null) {
            return
        }
        var settings = mergeSettings(entry.type, entry.settings)
        for (var key in changes) {
            settings[key] = changes[key]
        }
        updateWidget(id, { settings: settings })
    }

    function placeWidget(id, preset) {
        var entry = findWidget(id)
        if (entry === null) {
            return
        }

        var name = String(preset || "CENTER").toUpperCase()
        var horizontal = name.indexOf("LEFT") >= 0
            ? 0
            : name.indexOf("RIGHT") >= 0
                ? 1
                : 0.5
        var vertical = name.indexOf("TOP") >= 0
            ? 0
            : name.indexOf("BOTTOM") >= 0
                ? 1
                : 0.5

        updateWidget(id, { x: horizontal, y: vertical })
    }

    function resetMonitor(name) {
        var retained = []
        for (var index = 0; index < widgets.length; index++) {
            if (widgets[index].monitor !== name) {
                retained.push(widgets[index])
            }
        }
        widgets = retained.concat(defaultWidgets(name))
        selectedId = ""
        scheduleSave()
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
        widgetFile.setText(JSON.stringify({
            version: 2,
            enabled: enabled,
            snapSize: snapSize,
            activeMonitor: activeMonitor,
            monitorEnabled: monitorEnabled,
            widgets: widgets
        }, null, 2) + "\n")
    }

    function load() {
        var data = ({})
        var raw = widgetFile.text()
        if (raw && raw.trim().length > 0) {
            try {
                data = JSON.parse(raw)
            } catch (error) {
                console.warn("CHROMA widget layout was invalid; defaults restored")
            }
        }

        enabled = data.enabled !== false
        snapSize = Math.round(clamp(data.snapSize || 16, 4, 64))
        activeMonitor = String(data.activeMonitor || shell.resolvedBarMonitor)
        monitorEnabled = data.monitorEnabled || ({})

        var loaded = data.widgets || []
        var next = []
        for (var index = 0; index < loaded.length; index++) {
            next.push(normaliseWidget(loaded[index]))
        }
        widgets = next.length > 0 ? next : defaultWidgets(activeMonitor)
        ready = true
        saveTimer.restart()
    }

    Component.onCompleted: load()
}

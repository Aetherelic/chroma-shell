import QtQuick
import Quickshell
import Quickshell.Io

Scope {
    id: component

    required property var shell

    // The original CHROMA palettes stay first so existing saved theme
    // indexes remain compatible. Classic community palettes are appended.
    readonly property var themes: [
        {
            name: "VOLTAGE",
            family: "CHROMA ORIGINAL",
            description: "PINK // CYAN // YELLOW",
            ink: "#090a10",
            background: "#090b12",
            backgroundAlt: "#0b0d14",
            surface: "#11141d",
            surfaceAlt: "#1a1e29",
            surfaceHover: "#252a38",
            border: "#303442",
            borderStrong: "#353949",
            text: "#f2f2f7",
            textStrong: "#f4f4fa",
            muted: "#777e92",
            dim: "#62697b",
            success: "#45f0a8",
            warning: "#ffe66d",
            error: "#ff4f79",
            colours: [
                "#ff4f79", "#ff9f43", "#ffe66d", "#45f0a8",
                "#42c8ff", "#8f7cff", "#db5cff"
            ],
            spectrum: [
                "#45f0a8", "#42c8ff", "#8f7cff", "#db5cff",
                "#ff4f79", "#ff9f43", "#ffe66d"
            ]
        },
        {
            name: "TOXIC",
            family: "CHROMA ORIGINAL",
            description: "ACID // ORANGE // VIOLET",
            ink: "#090a10",
            background: "#0b0d0b",
            backgroundAlt: "#101410",
            surface: "#151a15",
            surfaceAlt: "#202720",
            surfaceHover: "#2b3529",
            border: "#394238",
            borderStrong: "#4b5748",
            text: "#f1f6e9",
            textStrong: "#f8ffe9",
            muted: "#9da68e",
            dim: "#6f7966",
            success: "#b7ff2a",
            warning: "#f7ff4a",
            error: "#ff7b2f",
            colours: [
                "#b7ff2a", "#ff7b2f", "#f7ff4a", "#35f0a1",
                "#16d9ff", "#8c5cff", "#ff3ac8"
            ],
            spectrum: [
                "#b7ff2a", "#35f0a1", "#16d9ff", "#8c5cff",
                "#ff3ac8", "#ff7b2f", "#f7ff4a"
            ]
        },
        {
            name: "ULTRAVIOLET",
            family: "CHROMA ORIGINAL",
            description: "MAGENTA // BLUE // VIOLET",
            ink: "#090a10",
            background: "#0c0b13",
            backgroundAlt: "#11101a",
            surface: "#171522",
            surfaceAlt: "#211e30",
            surfaceHover: "#302b43",
            border: "#403951",
            borderStrong: "#584c6d",
            text: "#f4f0ff",
            textStrong: "#fbf8ff",
            muted: "#9e96b5",
            dim: "#726a86",
            success: "#53efc4",
            warning: "#e8dd56",
            error: "#ff3ca6",
            colours: [
                "#ff3ca6", "#ff6b45", "#e8dd56", "#53efc4",
                "#4d8dff", "#8158ff", "#c642ff"
            ],
            spectrum: [
                "#53efc4", "#4d8dff", "#8158ff", "#c642ff",
                "#ff3ca6", "#ff6b45", "#e8dd56"
            ]
        },
        {
            name: "SOLAR FLARE",
            family: "CHROMA ORIGINAL",
            description: "CRIMSON // AMBER // GOLD",
            ink: "#0d0908",
            background: "#100b09",
            backgroundAlt: "#17100d",
            surface: "#211611",
            surfaceAlt: "#2f2018",
            surfaceHover: "#432c20",
            border: "#573a29",
            borderStrong: "#704b34",
            text: "#fff2df",
            textStrong: "#fff8ec",
            muted: "#b49a83",
            dim: "#806b5a",
            success: "#e7ff4f",
            warning: "#ffc83d",
            error: "#ff365f",
            colours: [
                "#ff365f", "#ff722f", "#ffc83d", "#e7ff4f",
                "#54d6ff", "#9f67ff", "#ff4a9b"
            ],
            spectrum: [
                "#e7ff4f", "#ffc83d", "#ff722f", "#ff365f",
                "#ff4a9b", "#9f67ff", "#54d6ff"
            ]
        },
        {
            name: "AQUA CIRCUIT",
            family: "CHROMA ORIGINAL",
            description: "TEAL // CYAN // ELECTRIC BLUE",
            ink: "#061012",
            background: "#071114",
            backgroundAlt: "#0b181c",
            surface: "#102126",
            surfaceAlt: "#172e34",
            surfaceHover: "#204149",
            border: "#2b5660",
            borderStrong: "#37707c",
            text: "#eaffff",
            textStrong: "#f4ffff",
            muted: "#8db4bb",
            dim: "#5f8087",
            success: "#42f5c2",
            warning: "#eaf55e",
            error: "#ff4f8b",
            colours: [
                "#ff4f8b", "#ff9b49", "#eaf55e", "#42f5c2",
                "#24d8ff", "#547cff", "#a94dff"
            ],
            spectrum: [
                "#42f5c2", "#24d8ff", "#547cff", "#a94dff",
                "#ff4f8b", "#ff9b49", "#eaf55e"
            ]
        },
        {
            name: "CANDY STATIC",
            family: "CHROMA ORIGINAL",
            description: "PASTEL NEON // HIGH ENERGY",
            ink: "#0b0910",
            background: "#0d0b12",
            backgroundAlt: "#14111a",
            surface: "#1b1722",
            surfaceAlt: "#27202f",
            surfaceHover: "#372c42",
            border: "#493a56",
            borderStrong: "#624d72",
            text: "#fff3ff",
            textStrong: "#fffaff",
            muted: "#b3a0ba",
            dim: "#806f88",
            success: "#60f0b8",
            warning: "#fff06a",
            error: "#ff4e88",
            colours: [
                "#ff4e88", "#ff8f66", "#fff06a", "#60f0b8",
                "#66d7ff", "#a67cff", "#f064e8"
            ],
            spectrum: [
                "#60f0b8", "#66d7ff", "#a67cff", "#f064e8",
                "#ff4e88", "#ff8f66", "#fff06a"
            ]
        },
        {
            name: "CATPPUCCIN MOCHA",
            family: "COMMUNITY CLASSIC",
            description: "MAUVE // PINK // PEACH",
            ink: "#11111b",
            background: "#1e1e2e",
            backgroundAlt: "#181825",
            surface: "#313244",
            surfaceAlt: "#45475a",
            surfaceHover: "#585b70",
            border: "#45475a",
            borderStrong: "#6c7086",
            text: "#cdd6f4",
            textStrong: "#f5e0dc",
            muted: "#a6adc8",
            dim: "#7f849c",
            success: "#a6e3a1",
            warning: "#f9e2af",
            error: "#f38ba8",
            colours: [
                "#f38ba8", "#fab387", "#f9e2af", "#a6e3a1",
                "#74c7ec", "#89b4fa", "#cba6f7"
            ],
            spectrum: [
                "#94e2d5", "#a6e3a1", "#f9e2af", "#fab387",
                "#f5c2e7", "#cba6f7", "#89b4fa"
            ]
        },
        {
            name: "GRUVBOX DARK",
            family: "COMMUNITY CLASSIC",
            description: "EARTH // AMBER // OLIVE",
            ink: "#1d2021",
            background: "#282828",
            backgroundAlt: "#1d2021",
            surface: "#3c3836",
            surfaceAlt: "#504945",
            surfaceHover: "#665c54",
            border: "#504945",
            borderStrong: "#7c6f64",
            text: "#ebdbb2",
            textStrong: "#fbf1c7",
            muted: "#a89984",
            dim: "#928374",
            success: "#b8bb26",
            warning: "#fabd2f",
            error: "#fb4934",
            colours: [
                "#fb4934", "#fe8019", "#fabd2f", "#b8bb26",
                "#83a598", "#d3869b", "#8ec07c"
            ],
            spectrum: [
                "#b8bb26", "#8ec07c", "#83a598", "#d3869b",
                "#fabd2f", "#fe8019", "#fb4934"
            ]
        },
        {
            name: "TOKYO NIGHT",
            family: "COMMUNITY CLASSIC",
            description: "CYAN // BLUE // MAGENTA",
            ink: "#101014",
            background: "#1a1b26",
            backgroundAlt: "#16161e",
            surface: "#24283b",
            surfaceAlt: "#292e42",
            surfaceHover: "#3b4261",
            border: "#3b4261",
            borderStrong: "#565f89",
            text: "#c0caf5",
            textStrong: "#d5d6f7",
            muted: "#a9b1d6",
            dim: "#565f89",
            success: "#9ece6a",
            warning: "#e0af68",
            error: "#f7768e",
            colours: [
                "#f7768e", "#ff9e64", "#e0af68", "#9ece6a",
                "#7dcfff", "#7aa2f7", "#bb9af7"
            ],
            spectrum: [
                "#73daca", "#7dcfff", "#7aa2f7", "#bb9af7",
                "#ff007c", "#f7768e", "#ff9e64"
            ]
        },
        {
            name: "NORD",
            family: "COMMUNITY CLASSIC",
            description: "FROST // AURORA // POLAR NIGHT",
            ink: "#242933",
            background: "#2e3440",
            backgroundAlt: "#242933",
            surface: "#3b4252",
            surfaceAlt: "#434c5e",
            surfaceHover: "#4c566a",
            border: "#4c566a",
            borderStrong: "#5e81ac",
            text: "#eceff4",
            textStrong: "#ffffff",
            muted: "#d8dee9",
            dim: "#7b88a1",
            success: "#a3be8c",
            warning: "#ebcb8b",
            error: "#bf616a",
            colours: [
                "#bf616a", "#d08770", "#ebcb8b", "#a3be8c",
                "#88c0d0", "#81a1c1", "#b48ead"
            ],
            spectrum: [
                "#8fbcbb", "#88c0d0", "#81a1c1", "#5e81ac",
                "#b48ead", "#d08770", "#ebcb8b"
            ]
        },
        {
            name: "ROSÉ PINE",
            family: "COMMUNITY CLASSIC",
            description: "ROSE // FOAM // IRIS",
            ink: "#191724",
            background: "#191724",
            backgroundAlt: "#1f1d2e",
            surface: "#26233a",
            surfaceAlt: "#403d52",
            surfaceHover: "#524f67",
            border: "#403d52",
            borderStrong: "#6e6a86",
            text: "#e0def4",
            textStrong: "#f2e9e1",
            muted: "#908caa",
            dim: "#6e6a86",
            success: "#9ccfd8",
            warning: "#f6c177",
            error: "#eb6f92",
            colours: [
                "#eb6f92", "#f6c177", "#ebbcba", "#9ccfd8",
                "#31748f", "#c4a7e7", "#908caa"
            ],
            spectrum: [
                "#9ccfd8", "#31748f", "#c4a7e7", "#eb6f92",
                "#f6c177", "#ebbcba", "#e0def4"
            ]
        },
        {
            name: "KANAGAWA",
            family: "COMMUNITY CLASSIC",
            description: "WAVE // AUTUMN // LOTUS",
            ink: "#16161d",
            background: "#1f1f28",
            backgroundAlt: "#16161d",
            surface: "#2a2a37",
            surfaceAlt: "#363646",
            surfaceHover: "#54546d",
            border: "#363646",
            borderStrong: "#727169",
            text: "#dcd7ba",
            textStrong: "#f2ecbc",
            muted: "#c8c093",
            dim: "#727169",
            success: "#98bb6c",
            warning: "#e6c384",
            error: "#e46876",
            colours: [
                "#e46876", "#ffa066", "#e6c384", "#98bb6c",
                "#7e9cd8", "#957fb8", "#7fb4ca"
            ],
            spectrum: [
                "#6a9589", "#7fb4ca", "#7e9cd8", "#957fb8",
                "#d27e99", "#ffa066", "#e6c384"
            ]
        },
        {
            name: "DRACULA",
            family: "COMMUNITY CLASSIC",
            description: "PURPLE // CYAN // PINK",
            ink: "#191a21",
            background: "#282a36",
            backgroundAlt: "#21222c",
            surface: "#343746",
            surfaceAlt: "#44475a",
            surfaceHover: "#55586a",
            border: "#44475a",
            borderStrong: "#6272a4",
            text: "#f8f8f2",
            textStrong: "#ffffff",
            muted: "#bfbfc4",
            dim: "#6272a4",
            success: "#50fa7b",
            warning: "#f1fa8c",
            error: "#ff5555",
            colours: [
                "#ff5555", "#ffb86c", "#f1fa8c", "#50fa7b",
                "#8be9fd", "#6272a4", "#bd93f9"
            ],
            spectrum: [
                "#50fa7b", "#8be9fd", "#6272a4", "#bd93f9",
                "#ff79c6", "#ffb86c", "#f1fa8c"
            ]
        },
        {
            name: "EVERFOREST DARK",
            family: "COMMUNITY CLASSIC",
            description: "GREEN // AQUA // AUTUMN",
            ink: "#232a2e",
            background: "#2d353b",
            backgroundAlt: "#232a2e",
            surface: "#343f44",
            surfaceAlt: "#3d484d",
            surfaceHover: "#475258",
            border: "#4f5b58",
            borderStrong: "#7a8478",
            text: "#d3c6aa",
            textStrong: "#f0ead3",
            muted: "#9da9a0",
            dim: "#7a8478",
            success: "#a7c080",
            warning: "#dbbc7f",
            error: "#e67e80",
            colours: [
                "#e67e80", "#e69875", "#dbbc7f", "#a7c080",
                "#83c092", "#7fbbb3", "#d699b6"
            ],
            spectrum: [
                "#a7c080", "#83c092", "#7fbbb3", "#d699b6",
                "#e67e80", "#e69875", "#dbbc7f"
            ]
        }
    ]

    property bool ready: false

    FileView {
        id: settingsFile
        path: Quickshell.statePath("settings.json")
        blockLoading: true
        atomicWrites: true
        printErrors: false
    }

    Timer {
        id: saveTimer
        interval: 120
        repeat: false
        onTriggered: component.save()
    }

    function normaliseIndex(index) {
        var count = themes.length
        if (count <= 0) {
            return 0
        }

        var value = Number(index)
        if (!isFinite(value)) {
            value = 0
        }

        value = Math.floor(value) % count
        return value < 0 ? value + count : value
    }

    function applyTheme(index, persist) {
        var resolved = normaliseIndex(index)
        var theme = themes[resolved]

        shell.themeIndex = resolved
        shell.themeName = theme.name
        shell.ink = theme.ink
        shell.background = theme.background
        shell.backgroundAlt = theme.backgroundAlt
        shell.surface = theme.surface
        shell.surfaceAlt = theme.surfaceAlt
        shell.surfaceHover = theme.surfaceHover
        shell.border = theme.border
        shell.borderStrong = theme.borderStrong
        shell.text = theme.text
        shell.textStrong = theme.textStrong
        shell.muted = theme.muted
        shell.dim = theme.dim
        shell.success = theme.success
        shell.warning = theme.warning
        shell.error = theme.error
        shell.palette = theme.colours.slice()
        shell.spectrumPalette = theme.spectrum.slice()

        if (persist !== false && ready) {
            saveTimer.restart()
        }
    }

    function cycleTheme(step) {
        applyTheme(shell.themeIndex + step, true)
    }

    function save() {
        if (!ready) {
            return
        }

        settingsFile.setText(JSON.stringify({
            theme: shell.themeIndex,
            doNotDisturb: shell.doNotDisturb
        }, null, 2) + "\n")
    }

    Component.onCompleted: {
        var data = ({})
        var raw = settingsFile.text()

        if (raw && raw.trim().length > 0) {
            try {
                data = JSON.parse(raw)
            } catch (error) {
                console.warn("CHROMA settings were invalid; defaults restored")
            }
        }

        applyTheme(data.theme !== undefined ? data.theme : 0, false)
        shell.doNotDisturb = data.doNotDisturb === true
        ready = true
        saveTimer.restart()
    }

    Connections {
        target: shell

        function onDoNotDisturbChanged() {
            if (component.ready) {
                saveTimer.restart()
            }
        }
    }
}

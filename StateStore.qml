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
        },
        {
            name: "MATRIX",
            family: "CHROMA DARK",
            description: "PHOSPHOR // BLACK // SIGNAL GREEN",
            ink: "#031006",
            background: "#020603",
            backgroundAlt: "#050b06",
            surface: "#08120a",
            surfaceAlt: "#0d1d10",
            surfaceHover: "#15301a",
            border: "#1f4427",
            borderStrong: "#2e6539",
            text: "#d8ffe0",
            textStrong: "#effff2",
            muted: "#7dae86",
            dim: "#507157",
            success: "#6dff8a",
            warning: "#d7ff68",
            error: "#ff5f76",
            colours: [
                "#58ff7b", "#9dff72", "#d7ff68", "#5ce8a0",
                "#47d8bc", "#64ad8b", "#8affc1"
            ],
            spectrum: [
                "#2eff65", "#58ff7b", "#86ff91", "#b8ff77",
                "#72e8a1", "#47d8bc", "#89ffd0"
            ]
        },
        {
            name: "MOONLIGHT",
            family: "CHROMA DARK",
            description: "NAVY // LAVENDER // COOL CYAN",
            ink: "#090b18",
            background: "#090d1f",
            backgroundAlt: "#0d1229",
            surface: "#141a34",
            surfaceAlt: "#1d2544",
            surfaceHover: "#29345c",
            border: "#34436d",
            borderStrong: "#4a5e91",
            text: "#e8ebff",
            textStrong: "#f7f8ff",
            muted: "#9aa4cc",
            dim: "#69749c",
            success: "#79e6c1",
            warning: "#f4d87a",
            error: "#ff6f9d",
            colours: [
                "#ff6f9d", "#f0a36f", "#f4d87a", "#79e6c1",
                "#62d7ff", "#8793ff", "#bd83ff"
            ],
            spectrum: [
                "#62d7ff", "#8793ff", "#bd83ff", "#ff6f9d",
                "#f0a36f", "#f4d87a", "#79e6c1"
            ]
        },
        {
            name: "EMBER",
            family: "CHROMA DARK",
            description: "CHARCOAL // COPPER // CREAM",
            ink: "#140b07",
            background: "#120d0b",
            backgroundAlt: "#19120f",
            surface: "#241914",
            surfaceAlt: "#33231b",
            surfaceHover: "#493125",
            border: "#5a3d2d",
            borderStrong: "#78523a",
            text: "#f8eadc",
            textStrong: "#fff7ee",
            muted: "#b49d8b",
            dim: "#816f61",
            success: "#b5d98d",
            warning: "#f6c66b",
            error: "#f36c5b",
            colours: [
                "#f36c5b", "#ef8b4a", "#f6c66b", "#b5d98d",
                "#76b8c4", "#aa82c9", "#d9769c"
            ],
            spectrum: [
                "#f6c66b", "#ef8b4a", "#f36c5b", "#d9769c",
                "#aa82c9", "#76b8c4", "#b5d98d"
            ]
        },
        {
            name: "AURORA",
            family: "CHROMA DARK",
            description: "TEAL // VIOLET // PINK // MINT",
            ink: "#061012",
            background: "#071116",
            backgroundAlt: "#0b171e",
            surface: "#10222a",
            surfaceAlt: "#18323b",
            surfaceHover: "#234650",
            border: "#2d5963",
            borderStrong: "#3c7580",
            text: "#eaffff",
            textStrong: "#f6ffff",
            muted: "#8fb7bd",
            dim: "#63838a",
            success: "#57f0bd",
            warning: "#f4e66b",
            error: "#ff5c91",
            colours: [
                "#ff5c91", "#ff9364", "#f4e66b", "#57f0bd",
                "#42d8f5", "#8b78ff", "#d45cff"
            ],
            spectrum: [
                "#57f0bd", "#42d8f5", "#8b78ff", "#d45cff",
                "#ff5c91", "#ff9364", "#f4e66b"
            ]
        },
        {
            name: "MIDNIGHT SIGNAL",
            family: "CHROMA DARK",
            description: "DEEP BLUE // SIGNAL RED // ICE",
            ink: "#070b16",
            background: "#050916",
            backgroundAlt: "#090f20",
            surface: "#0f1830",
            surfaceAlt: "#172443",
            surfaceHover: "#21325a",
            border: "#2a3f6c",
            borderStrong: "#3b568d",
            text: "#e6efff",
            textStrong: "#f5f9ff",
            muted: "#8fa1c4",
            dim: "#607293",
            success: "#67e3c1",
            warning: "#f1d56a",
            error: "#ff5472",
            colours: [
                "#ff5472", "#ff8b55", "#f1d56a", "#67e3c1",
                "#4ac9ff", "#6688ff", "#aa6fff"
            ],
            spectrum: [
                "#4ac9ff", "#6688ff", "#aa6fff", "#ff5472",
                "#ff8b55", "#f1d56a", "#67e3c1"
            ]
        },
        {
            name: "SUNLIGHT",
            family: "CHROMA LIGHT",
            description: "IVORY // AMBER // CORAL // SKY",
            ink: "#24180e",
            background: "#fff8e9",
            backgroundAlt: "#f8ecd4",
            surface: "#fffdf7",
            surfaceAlt: "#f0dfbf",
            surfaceHover: "#ead3ad",
            border: "#d6bd94",
            borderStrong: "#b99b6e",
            text: "#35291d",
            textStrong: "#21170e",
            muted: "#756653",
            dim: "#9b8970",
            success: "#2b9d70",
            warning: "#c98216",
            error: "#d94d5e",
            colours: [
                "#e85568", "#ee8b32", "#d7a817", "#2ba879",
                "#278dc1", "#7167d8", "#b652b1"
            ],
            spectrum: [
                "#2ba879", "#278dc1", "#7167d8", "#b652b1",
                "#e85568", "#ee8b32", "#d7a817"
            ]
        },
        {
            name: "PAPERWAVE",
            family: "CHROMA LIGHT",
            description: "PAPER // MUTED RGB // GRAPHITE",
            ink: "#18191c",
            background: "#f2f0eb",
            backgroundAlt: "#e7e4dd",
            surface: "#faf9f6",
            surfaceAlt: "#ddd9d0",
            surfaceHover: "#d1ccc1",
            border: "#bbb5aa",
            borderStrong: "#928b80",
            text: "#2e3036",
            textStrong: "#17191e",
            muted: "#6d6f74",
            dim: "#929397",
            success: "#3a956e",
            warning: "#b8842e",
            error: "#c95267",
            colours: [
                "#c95267", "#d27c4d", "#b99a38", "#3a956e",
                "#3a85a9", "#6d68b5", "#a5539c"
            ],
            spectrum: [
                "#3a956e", "#3a85a9", "#6d68b5", "#a5539c",
                "#c95267", "#d27c4d", "#b99a38"
            ]
        },
        {
            name: "GLACIER",
            family: "CHROMA LIGHT",
            description: "COOL WHITE // SLATE // ICE CYAN",
            ink: "#101820",
            background: "#eef6f8",
            backgroundAlt: "#e1edf0",
            surface: "#f9fdfe",
            surfaceAlt: "#d5e5e9",
            surfaceHover: "#c6dce1",
            border: "#a9c4cb",
            borderStrong: "#7eabb5",
            text: "#263841",
            textStrong: "#12242c",
            muted: "#617b84",
            dim: "#8ba1a8",
            success: "#2d9e84",
            warning: "#bd8c2d",
            error: "#cf566e",
            colours: [
                "#cf566e", "#d47d4e", "#bd9b35", "#2d9e84",
                "#238fb7", "#6279c9", "#9a5eb8"
            ],
            spectrum: [
                "#2d9e84", "#238fb7", "#6279c9", "#9a5eb8",
                "#cf566e", "#d47d4e", "#bd9b35"
            ]
        },
        {
            name: "SAKURA DAY",
            family: "CHROMA LIGHT",
            description: "CREAM // ROSE // PLUM",
            ink: "#24151d",
            background: "#fff4f1",
            backgroundAlt: "#f5e4e1",
            surface: "#fffaf8",
            surfaceAlt: "#edd6d5",
            surfaceHover: "#e3c6c8",
            border: "#cda9ae",
            borderStrong: "#ad818a",
            text: "#432d36",
            textStrong: "#28171f",
            muted: "#846a73",
            dim: "#a58d94",
            success: "#3d9877",
            warning: "#bd832e",
            error: "#d84f78",
            colours: [
                "#d84f78", "#df765a", "#c79b42", "#3d9877",
                "#448fab", "#756ac1", "#a84f99"
            ],
            spectrum: [
                "#3d9877", "#448fab", "#756ac1", "#a84f99",
                "#d84f78", "#df765a", "#c79b42"
            ]
        },
        {
            name: "MONO DARK",
            family: "MONOCHROME",
            description: "BLACK // GRAPHITE // WHITE",
            ink: "#050505",
            background: "#050505",
            backgroundAlt: "#0b0b0b",
            surface: "#141414",
            surfaceAlt: "#202020",
            surfaceHover: "#303030",
            border: "#3d3d3d",
            borderStrong: "#575757",
            text: "#dddddd",
            textStrong: "#ffffff",
            muted: "#9a9a9a",
            dim: "#707070",
            success: "#c7c7c7",
            warning: "#e7e7e7",
            error: "#b8b8b8",
            colours: [
                "#f2f2f2", "#d8d8d8", "#bebebe", "#a4a4a4",
                "#8a8a8a", "#707070", "#565656"
            ],
            spectrum: [
                "#565656", "#707070", "#8a8a8a", "#a4a4a4",
                "#bebebe", "#d8d8d8", "#f2f2f2"
            ]
        },
        {
            name: "MONO LIGHT",
            family: "MONOCHROME",
            description: "WHITE // SILVER // BLACK",
            ink: "#111111",
            background: "#f3f3f3",
            backgroundAlt: "#e8e8e8",
            surface: "#ffffff",
            surfaceAlt: "#dcdcdc",
            surfaceHover: "#cdcdcd",
            border: "#b7b7b7",
            borderStrong: "#8b8b8b",
            text: "#333333",
            textStrong: "#111111",
            muted: "#686868",
            dim: "#929292",
            success: "#444444",
            warning: "#2f2f2f",
            error: "#555555",
            colours: [
                "#111111", "#333333", "#555555", "#777777",
                "#999999", "#bbbbbb", "#dddddd"
            ],
            spectrum: [
                "#dddddd", "#bbbbbb", "#999999", "#777777",
                "#555555", "#333333", "#111111"
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

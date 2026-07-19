import QtQuick
import Quickshell
import Quickshell.Io

Scope {
    id: distro

    property string distroId: "linux"
    property string distroLike: ""
    property string prettyName: "Linux"

    readonly property string glyph:
        resolveGlyph(distroId, distroLike)

    FileView {
        id: osReleaseFile
        path: "/etc/os-release"
        blockLoading: true
        atomicWrites: false
        printErrors: false
    }

    function cleanValue(value) {
        var result = String(value || "").trim()

        if (result.length >= 2) {
            var first = result.charAt(0)
            var last = result.charAt(result.length - 1)

            if ((first === '"' && last === '"')
                    || (first === "'" && last === "'")) {
                result = result.substring(1, result.length - 1)
            }
        }

        return result
    }

    function parseOsRelease(raw) {
        var values = ({})
        var lines = String(raw || "").split("\n")

        for (var index = 0; index < lines.length; index++) {
            var line = lines[index].trim()

            if (line.length === 0 || line.charAt(0) === "#") {
                continue
            }

            var separator = line.indexOf("=")
            if (separator <= 0) {
                continue
            }

            var key = line.substring(0, separator).trim()
            var value = line.substring(separator + 1)
            values[key] = cleanValue(value)
        }

        distroId = String(values.ID || "linux").toLowerCase()
        distroLike = String(values.ID_LIKE || "").toLowerCase()
        prettyName = String(
            values.PRETTY_NAME
            || values.NAME
            || distroId
            || "Linux"
        )
    }

    function matches(id, like, candidates) {
        var words = (
            " " + String(id || "").toLowerCase()
            + " " + String(like || "").toLowerCase() + " "
        )

        for (var index = 0; index < candidates.length; index++) {
            if (words.indexOf(" " + candidates[index] + " ") >= 0) {
                return true
            }
        }

        return false
    }

    function resolveGlyph(id, like) {
        if (matches(id, like, ["nixos"])) {
            return "\uf313"
        }

        if (matches(id, like, [
            "arch", "archlinux", "cachyos", "endeavouros",
            "garuda", "artix", "manjaro"
        ])) {
            return "\uf303"
        }

        if (matches(id, like, ["fedora", "nobara"])) {
            return "\uf30a"
        }

        if (matches(id, like, [
            "ubuntu", "pop", "pop_os", "linuxmint", "mint"
        ])) {
            return "\uf31b"
        }

        if (matches(id, like, ["debian"])) {
            return "\uf306"
        }

        return "\uf17c"
    }

    Component.onCompleted:
        parseOsRelease(osReleaseFile.text())
}

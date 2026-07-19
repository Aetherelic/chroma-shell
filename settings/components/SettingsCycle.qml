import QtQuick
import QtQuick.Layouts

Item {
    id: control

    required property var shell

    property string label: "VALUE"
    property var options: []
    property string current: ""
    property color accent: shell.uiPalette[4]

    signal optionSelected(string value)

    implicitHeight: 46
    implicitWidth: 520

    function currentIndex() {
        var index = options.indexOf(current)
        return index >= 0 ? index : 0
    }

    function cycle(step) {
        if (options.length === 0) {
            return
        }

        var index = (currentIndex() + step + options.length) % options.length
        optionSelected(String(options[index]))
    }

    RowLayout {
        anchors.fill: parent
        spacing: 12

        Text {
            Layout.fillWidth: true
            text: control.label.toUpperCase()
            color: shell.text
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: Math.round(11 * shell.fontScale)
            font.weight: Font.Black
            font.letterSpacing: 0.8
            elide: Text.ElideRight
        }

        SettingsButton {
            shell: control.shell
            label: "‹"
            implicitWidth: 42
            onClicked: control.cycle(-1)
        }

        Rectangle {
            Layout.preferredWidth: 220
            Layout.preferredHeight: 40
            color: shell.backgroundAlt
            border.width: shell.borderWidth
            border.color: shell.border
            radius: shell.controlRadius

            Text {
                anchors.centerIn: parent
                width: parent.width - 16
                text: control.current.length > 0 ? control.current : "—"
                color: control.accent
                horizontalAlignment: Text.AlignHCenter
                elide: Text.ElideRight
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: Math.round(11 * shell.fontScale)
                font.weight: Font.Black
            }
        }

        SettingsButton {
            shell: control.shell
            label: "›"
            implicitWidth: 42
            onClicked: control.cycle(1)
        }
    }
}

import QtQuick
import QtQuick.Layouts

Item {
    id: control

    required property var shell

    property string label: "VALUE"
    property string description: ""
    property real value: 0
    property real minimum: 0
    property real maximum: 100
    property real step: 1
    property int decimals: 0
    property string suffix: ""
    property color accent: shell.uiPalette[4]

    signal valueSelected(real value)

    implicitHeight: 44
    implicitWidth: 420

    function nextValue(delta) {
        var candidate = Math.max(
            minimum,
            Math.min(maximum, value + delta)
        )
        var factor = Math.pow(10, decimals)
        return Math.round(candidate * factor) / factor
    }

    RowLayout {
        anchors.fill: parent
        spacing: 12

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 3

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

        }

        SettingsButton {
            shell: control.shell
            label: "−"
            enabled: control.value > control.minimum
            onClicked: control.valueSelected(control.nextValue(-control.step))
        }

        Rectangle {
            Layout.preferredWidth: 82
            Layout.preferredHeight: 40
            color: shell.backgroundAlt
            border.width: shell.borderWidth
            border.color: shell.border
            radius: shell.controlRadius

            Text {
                anchors.centerIn: parent
                text: Number(control.value).toFixed(control.decimals) + control.suffix
                color: control.accent
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: Math.round(12 * shell.fontScale)
                font.weight: Font.Black
            }
        }

        SettingsButton {
            shell: control.shell
            label: "+"
            enabled: control.value < control.maximum
            onClicked: control.valueSelected(control.nextValue(control.step))
        }
    }
}

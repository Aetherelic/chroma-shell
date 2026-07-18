import QtQuick
import QtQuick.Layouts

Item {
    id: control

    required property var shell

    property string label: "CHOICE"
    property string description: ""
    property var options: []
    property string current: ""
    property color accent: shell.uiPalette[4]

    signal optionSelected(string value)

    implicitHeight: 56
    implicitWidth: 480

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
                font.pixelSize: Math.round(10 * shell.fontScale)
                font.weight: Font.Black
                font.letterSpacing: 0.8
                elide: Text.ElideRight
            }

        }

        RowLayout {
            spacing: 6

            Repeater {
                model: control.options

                SettingsButton {
                    required property var modelData
                    shell: control.shell
                    label: String(modelData)
                    filled: control.current === String(modelData)
                    accent: control.accent
                    onClicked: control.optionSelected(String(modelData))
                }
            }
        }
    }
}

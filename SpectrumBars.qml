import QtQuick

Item {
    id: root

    required property var values
    required property var palette

    property real barWidth: 4
    property real barSpacing: 3
    property real minimumBarHeight: 2
    property bool active: true

    implicitWidth:
        Math.max(
            0,
            values.length * barWidth
            + Math.max(0, values.length - 1) * barSpacing
        )

    implicitHeight: 40

    Row {
        anchors.centerIn: parent
        height: parent.height
        spacing: root.barSpacing

        Repeater {
            model: root.values.length

            Item {
                id: barSlot

                required property int index

                width: root.barWidth
                height: parent.height

                Rectangle {
                    anchors {
                        left: parent.left
                        right: parent.right
                        bottom: parent.bottom
                    }

                    height:
                        root.active
                            ? Math.max(
                                root.minimumBarHeight,
                                parent.height
                                * Math.max(
                                    0,
                                    Math.min(
                                        1,
                                        root.values[barSlot.index]
                                    )
                                )
                            )
                            : root.minimumBarHeight

                    radius: 1

                    color:
                        root.palette[
                            Math.min(
                                root.palette.length - 1,
                                Math.floor(
                                    barSlot.index
                                    * root.palette.length
                                    / Math.max(1, root.values.length)
                                )
                            )
                        ]

                    opacity:
                        root.active
                            ? 0.42
                                + Math.max(
                                    0,
                                    Math.min(
                                        1,
                                        root.values[barSlot.index]
                                    )
                                ) * 0.58
                            : 0.24

                    Behavior on height {
                        NumberAnimation {
                            duration: 58
                            easing.type: Easing.OutCubic
                        }
                    }

                    Behavior on opacity {
                        NumberAnimation {
                            duration: 80
                        }
                    }
                }
            }
        }
    }
}

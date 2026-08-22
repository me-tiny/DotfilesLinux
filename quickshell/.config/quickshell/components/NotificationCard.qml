import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.Notifications

import qs.config
import qs.components
import qs.services as Services

Rectangle {
    id: card
    required property var notif
    property bool popup: false

    signal acted()

    Component.onCompleted: if (!notif) Services.Notifications.prune()

    readonly property bool exiting: popup && Services.Notifications.exiting.includes(notif)

    readonly property bool critical: notif && notif.urgency === NotificationUrgency.Critical
    readonly property var defaultAction: {
        if (!notif) return null
        for (const a of notif.actions)
            if (a.identifier === "default") return a
        return null
    }
    readonly property var buttonActions: notif ? notif.actions.filter(a => a.identifier !== "default") : []
    readonly property real progressValue:
        notif && notif.hints && notif.hints.value !== undefined ? Number(notif.hints.value) : -1

    implicitHeight: content.implicitHeight + 20
    x: exiting ? width + 48 : 0
    opacity: exiting ? 0 : 1

    Behavior on x {
        enabled: card.popup
        NumberAnimation { duration: 220; easing.type: Easing.InQuad }
    }
    Behavior on opacity {
        enabled: card.popup
        NumberAnimation { duration: 200 }
    }

    radius: Theme.popupRounding
    color: popup ? Theme.base : Theme.surface0
    border.width: 1
    border.color: critical ? Theme.red : Theme.overlay

    HoverHandler {
        id: hover
        onHoveredChanged: {
            if (card.popup)
                Services.Notifications.hold(card.notif, hovered)
        }
    }

    readonly property bool dbgHovered: hover.hovered

    RetainableLock {
        object: card.notif
        locked: true
    }

    Timer {
        running: card.exiting
        interval: 240
        onTriggered: Services.Notifications.finalizeHide(card.notif)
    }

    MouseArea {
        anchors.fill: parent
        enabled: card.defaultAction !== null
        onClicked: {
            card.defaultAction.invoke()
            card.notif.dismiss()
            card.acted()
        }
    }

    RowLayout {
        id: content
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: 10
        spacing: 10

        Item {
            visible: card.notif && (card.notif.image !== "" || card.notif.appIcon !== "")
            Layout.preferredWidth: 48
            Layout.preferredHeight: 48
            Layout.alignment: Qt.AlignTop

            ClippingRectangle {
                anchors.fill: parent
                radius: Theme.rounding
                color: "transparent"

                Image {
                    visible: card.notif && card.notif.image !== ""
                    anchors.fill: parent
                    source: card.notif ? card.notif.image : ""
                    fillMode: Image.PreserveAspectCrop
                    asynchronous: true
                }

                IconImage {
                    visible: card.notif && card.notif.image === "" && card.notif.appIcon !== ""
                    anchors.fill: parent
                    source: card.notif && card.notif.appIcon !== ""
                            ? Quickshell.iconPath(card.notif.appIcon, true) : ""
                    asynchronous: true
                }
            }

            IconImage {
                visible: card.notif && card.notif.image !== "" && card.notif.appIcon !== ""
                width: 18
                height: 18
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                source: card.notif && card.notif.appIcon !== ""
                        ? Quickshell.iconPath(card.notif.appIcon, true) : ""
                asynchronous: true
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 4

            RowLayout {
                Layout.fillWidth: true
                spacing: 6

                BarText {
                    Layout.fillWidth: true
                    text: card.notif ? card.notif.summary : ""
                    weight: Font.Bold
                    elide: Text.ElideRight
                    maximumLineCount: 2
                    wrapMode: Text.Wrap
                }

                BarText {
                    visible: !card.popup
                    text: card.notif ? Services.Notifications.ago(card.notif.id) : ""
                    color: Theme.overlay
                    font.pixelSize: Theme.fontSizeSmall - 2
                }

                Rectangle {
                    Layout.preferredWidth: 22
                    Layout.preferredHeight: 22
                    Layout.alignment: Qt.AlignTop
                    radius: Theme.rounding
                    color: Theme.red
                    opacity: closeHover.containsMouse ? 1 : 0.85

                    BarText {
                        anchors.centerIn: parent
                        text: "󰅖"
                        color: Theme.base
                        font.pixelSize: Theme.fontSizeSmall
                    }

                    MouseArea {
                        id: closeHover
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: card.notif ? card.notif.dismiss()
                                              : Services.Notifications.prune()
                    }
                }
            }

            BarText {
                Layout.fillWidth: true
                visible: text !== ""
                text: card.notif ? card.notif.body : ""
                color: Theme.subtext
                font.pixelSize: Theme.fontSizeSmall
                textFormat: Text.StyledText
                wrapMode: Text.Wrap
                elide: Text.ElideRight
                maximumLineCount: 8
                onLinkActivated: (link) => Qt.openUrlExternally(link)
            }

            Rectangle {
                visible: card.progressValue >= 0
                Layout.fillWidth: true
                Layout.topMargin: 2
                implicitHeight: 8
                radius: 4
                color: card.popup ? Theme.surface0 : Theme.surface1

                Rectangle {
                    anchors.left: parent.left
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    width: parent.width * Math.max(0, Math.min(100, card.progressValue)) / 100
                    radius: 4
                    color: card.critical ? Theme.red : Theme.blue
                }
            }

            RowLayout {
                visible: card.buttonActions.length > 0
                Layout.fillWidth: true
                Layout.topMargin: 4
                spacing: 6

                Repeater {
                    model: card.buttonActions
                    delegate: Rectangle {
                        id: actionButton
                        required property var modelData

                        Layout.fillWidth: true
                        implicitHeight: 30
                        radius: Theme.rounding
                        color: actionHover.containsMouse ? Theme.hover : "transparent"
                        border.width: 1
                        border.color: Theme.overlay

                        BarText {
                            anchors.centerIn: parent
                            width: parent.width - 12
                            horizontalAlignment: Text.AlignHCenter
                            text: actionButton.modelData.text || actionButton.modelData.identifier
                            font.pixelSize: Theme.fontSizeSmall
                            elide: Text.ElideRight
                        }

                        MouseArea {
                            id: actionHover
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: {
                                actionButton.modelData.invoke()
                                card.notif.dismiss()
                                card.acted()
                            }
                        }
                    }
                }
            }
        }
    }
}

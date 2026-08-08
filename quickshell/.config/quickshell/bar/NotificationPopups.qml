import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland

import qs.config
import qs.components
import qs.services as Services

PanelWindow {
    id: win

    screen: Hyprland.focusedMonitor?.screen ?? Quickshell.screens[0]
    anchors { top: true; right: true }
    margins { top: 8 }
    exclusiveZone: 0
    color: "transparent"
    surfaceFormat.opaque: false

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "quickshell:notifications"

    implicitWidth: 448
    implicitHeight: Theme.popoutSpace

    mask: Region {
        x: 20
        y: 0
        width: 420
        height: lv.contentHeight
    }

    ListView {
        id: lv
        anchors.fill: parent
        anchors.leftMargin: 20
        anchors.rightMargin: 8
        spacing: 8
        interactive: false

        model: ScriptModel {
            values: Services.Notifications.popups
        }

        delegate: NotificationCard {
            required property var modelData
            width: ListView.view.width
            notif: modelData
            popup: true
        }

        add: Transition {
            NumberAnimation {
                property: "x"
                from: lv.width + 8
                to: 0
                duration: 340
                easing.type: Easing.OutBack
                easing.overshoot: 0.7
            }
            NumberAnimation { property: "opacity"; from: 0; to: 1; duration: 140 }
        }

        populate: Transition {
            NumberAnimation {
                property: "x"
                from: lv.width + 8
                to: 0
                duration: 340
                easing.type: Easing.OutBack
                easing.overshoot: 0.7
            }
            NumberAnimation { property: "opacity"; from: 0; to: 1; duration: 140 }
        }

        displaced: Transition {
            NumberAnimation {
                properties: "x,y"
                duration: 240
                easing.type: Easing.OutQuint
            }
            NumberAnimation { property: "opacity"; to: 1; duration: 120 }
        }
    }
}

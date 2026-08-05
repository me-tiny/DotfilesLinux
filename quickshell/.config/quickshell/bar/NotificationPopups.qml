import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland

import qs.components
import qs.services as Services

PanelWindow {
    id: win

    screen: Hyprland.focusedMonitor?.screen ?? Quickshell.screens[0]
    anchors { top: true; right: true }
    margins { top: 8; right: 8 }
    exclusiveZone: 0
    color: "transparent"
    surfaceFormat.opaque: false
    visible: Services.Notifications.popups.length > 0

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "quickshell:notifications"

    implicitWidth: 420
    implicitHeight: col.implicitHeight

    Column {
        id: col
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        spacing: 8

        Repeater {
            model: Services.Notifications.popups
            delegate: NotificationCard {
                required property var modelData
                width: col.width
                notif: modelData
                popup: true
            }
        }
    }
}

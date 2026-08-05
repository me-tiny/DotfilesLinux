import QtQuick
import Quickshell.Hyprland

import qs.config
import qs.components
import qs.services as Services

Item {
    id: root
    required property var panel

    property string mode: "closed"
    property var menuRoot: null
    property var menuStack: []
    readonly property bool overlayOpen: mode !== "closed"

    property bool popupHovered: false
    property bool bridgeHovered: false
    readonly property bool pointerInside:
        buttonHover.containsMouse || popupHovered || bridgeHovered

    onModeChanged: Services.Notifications.centerOpen = (mode === "drawer")

    function showDrawer() {
        _beginOverlay()
        Qt.callLater(() => mode = "drawer")
    }

    function showMenuFor(item) {
        if (!item || !item.hasMenu) return
        menuRoot = item.menu
        menuStack = []
        _beginOverlay()
        Qt.callLater(() => mode = "menu")
    }

    function backToDrawer() {
        menuStack = []
        menuRoot = null
        mode = "drawer"
    }

    function pushMenu(entry) { menuStack = menuStack.concat([entry]) }
    function popMenu()        { menuStack = menuStack.slice(0, -1) }

    function closeAll() {
        mode = "closed"
        _endOverlay()
    }

    function clearMenus() {
        menuStack = []
        menuRoot = null
    }

    function _beginOverlay() {
        panel.focusable = true
        focusGrab.active = true
    }

    function _endOverlay() {
        panel.focusable = false
        focusGrab.active = false
    }

    onPointerInsideChanged: {
        if (!overlayOpen) return
        if (pointerInside) hoverDismiss.stop()
        else hoverDismiss.restart()
    }

    Timer {
        id: hoverDismiss
        interval: 150
        repeat: false
        onTriggered: { if (overlayOpen && !pointerInside) closeAll() }
    }

    HyprlandFocusGrab {
        id: focusGrab
        active: false
        windows: [ panel ]
        onCleared: closeAll()
    }

    implicitWidth: button.implicitWidth
    implicitHeight: button.implicitHeight

    Rectangle {
        id: button
        implicitWidth: 24
        implicitHeight: 24
        radius: Theme.rounding
        color: buttonHover.containsMouse ? Theme.hover : "transparent"

        BarText {
            anchors.centerIn: parent
            text: "\ud804\udc54"
            font.pixelSize: Theme.fontSizeIcon
        }

        Rectangle {
            visible: Services.Notifications.dnd || Services.Notifications.list.length > 0
            width: 7
            height: 7
            radius: width / 2
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.margins: 2
            color: Services.Notifications.dnd ? Theme.teal
                 : Services.Notifications.hasCritical ? Theme.red
                 : Theme.text
        }

        MouseArea {
            id: buttonHover
            anchors.fill: parent
            hoverEnabled: true
            acceptedButtons: Qt.LeftButton
            onClicked: root.mode === "drawer" ? root.closeAll() : root.showDrawer()
        }
    }


    TrayPopup {
        id: popup
        tray: root
    }
}

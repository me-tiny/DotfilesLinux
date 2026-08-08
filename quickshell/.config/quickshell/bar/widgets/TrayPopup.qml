import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.SystemTray

import qs.config
import qs.components
import qs.services as Services

Rectangle {
    id: popout
    required property var tray

    Component.onCompleted: {
        parent = tray.panel.contentItem
        tray.panel.popout = popout
    }

    readonly property int tuck: 2
    z: -1
    clip: true

    anchors.top: parent.top
    anchors.topMargin: Theme.barHeight - tuck
    anchors.right: parent.right

    property string view: "drawer"

    readonly property bool open: tray.mode !== "closed"
    readonly property bool engaged: open || opacity > 0
    visible: engaged

    readonly property int drawerWidth: Math.max(420, Math.min(460, drawerRow.implicitWidth + 16))

    readonly property int contentHeight: Math.min(
        Theme.popoutSpace,
        view === "menu" ? menuCol.implicitHeight + 16 + tuck
                        : drawerCol.implicitHeight)

    onEngagedChanged: if (!engaged) tray.clearMenus()

    onOpenChanged: if (open) keys.forceActiveFocus()

    width: drawerWidth
    // full-size while engaged; zero when closed so the bar's input mask
    // region collapses with it
    height: engaged ? contentHeight : 0

    // macOS popover: appear full-size, scale from the bar edge with a fade
    scale: open ? 1 : 0.96
    opacity: open ? 1 : 0
    transformOrigin: Item.TopRight

    Behavior on scale {
        NumberAnimation {
            duration: popout.open ? 240 : 140
            easing.type: popout.open ? Easing.OutBack : Easing.InQuad
        }
    }

    Behavior on opacity {
        NumberAnimation {
            duration: popout.open ? 170 : 130
            easing.type: popout.open ? Easing.OutQuad : Easing.InQuad
        }
    }

    // only animate content-size changes while open; open/close snaps so the
    // popover never height-reveals
    Behavior on height {
        enabled: popout.open && popout.height > 0
        NumberAnimation { duration: 240; easing.type: Easing.OutQuint }
    }
    Behavior on width { NumberAnimation { duration: 240; easing.type: Easing.OutQuint } }

    color: Theme.base
    radius: Theme.popupRounding
    topLeftRadius: 0
    topRightRadius: 0
    bottomRightRadius: 0

    HoverHandler {
        onHoveredChanged: popout.tray.popupHovered = hovered
    }

    Item {
        id: hoverBridge
        parent: popout.parent
        visible: popout.open
        anchors.top: parent.top
        anchors.right: parent.right
        width: popout.width
        height: Theme.barHeight

        HoverHandler {
            onHoveredChanged: popout.tray.bridgeHovered = hovered
        }
    }

    FocusScope {
        id: keys
        focus: popout.open
        Keys.onEscapePressed: (e) => { popout.tray.closeAll(); e.accepted = true }
    }

    Connections {
        target: popout.tray
        function onModeChanged() {
            if (popout.tray.mode !== "closed")
                popout.view = popout.tray.mode
        }
    }

    QsMenuOpener {
        id: opener
        menu: popout.tray.menuStack.length > 0
              ? popout.tray.menuStack[popout.tray.menuStack.length - 1]
              : popout.tray.menuRoot
    }

    Column {
        id: drawerCol
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        visible: opacity > 0
        enabled: popout.view === "drawer"
        opacity: popout.view === "drawer" ? 1 : 0
        transform: Translate {
            x: popout.view === "drawer" ? 0 : -16
            Behavior on x { NumberAnimation { duration: 260; easing.type: Easing.OutQuint } }
        }
        Behavior on opacity { NumberAnimation { duration: 150 } }
        padding: 8
        topPadding: 8 + popout.tuck
        spacing: 6

        RowLayout {
            id: drawerRow
            spacing: 4
            visible: SystemTray.items.values.length > 0

            Repeater {
                model: SystemTray.items
                delegate: Rectangle {
                    id: iconCell
                    required property var modelData

                    Layout.preferredWidth: 32
                    Layout.preferredHeight: 32
                    radius: Theme.rounding
                    color: iconHover.containsMouse ? Theme.hover : "transparent"

                    IconImage {
                        anchors.centerIn: parent
                        width: 22
                        height: 22
                        source: iconCell.modelData.icon
                    }

                    MouseArea {
                        id: iconHover
                        anchors.fill: parent
                        hoverEnabled: true
                        acceptedButtons: Qt.LeftButton | Qt.RightButton
                        onClicked: (mouse) => {
                            if (mouse.button === Qt.LeftButton) {
                                iconCell.modelData.activate()
                                popout.tray.closeAll()
                            } else if (mouse.button === Qt.RightButton) {
                                popout.tray.showMenuFor(iconCell.modelData)
                            }
                        }
                    }
                }
            }
        }

        Rectangle {
            visible: drawerRow.visible
            width: parent.width - 16
            height: 1
            color: Theme.overlay
            opacity: 0.4
        }

        RowLayout {
            width: parent.width - 16
            spacing: 6

            BarText {
                text: "Notifications"
                color: Theme.mauve
                weight: Font.Bold
                font.pixelSize: Theme.fontSizeSmall
            }

            Item { Layout.fillWidth: true }

            Rectangle {
                implicitWidth: 26
                implicitHeight: 26
                radius: Theme.rounding
                color: dndHover.containsMouse ? Theme.hover : "transparent"

                BarText {
                    anchors.centerIn: parent
                    text: Services.Notifications.dnd ? "󰂛" : "󰂚"
                    color: Services.Notifications.dnd ? Theme.teal : Theme.text
                    font.pixelSize: Theme.fontSizeSmall
                }

                MouseArea {
                    id: dndHover
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: Services.Notifications.dnd = !Services.Notifications.dnd
                }
            }

            Rectangle {
                visible: Services.Notifications.list.length > 0
                implicitWidth: clearText.implicitWidth + 16
                implicitHeight: 26
                radius: Theme.rounding
                color: clearHover.containsMouse ? Theme.hover : "transparent"
                border.width: 1
                border.color: Theme.overlay

                BarText {
                    id: clearText
                    anchors.centerIn: parent
                    text: "Clear"
                    font.pixelSize: Theme.fontSizeSmall
                }

                MouseArea {
                    id: clearHover
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: Services.Notifications.clearAll()
                }
            }
        }

        BarText {
            visible: Services.Notifications.list.length === 0
            width: parent.width - 16
            text: "No notifications"
            color: Theme.overlay
            font.pixelSize: Theme.fontSizeSmall
            horizontalAlignment: Text.AlignHCenter
            topPadding: 8
            bottomPadding: 8
        }

        ListView {
            id: centerList
            visible: Services.Notifications.list.length > 0
            width: parent.width - 16
            implicitHeight: Math.min(contentHeight, Theme.popoutSpace - 140)
            clip: true
            spacing: 6

            model: ScriptModel {
                values: Services.Notifications.list
            }

            delegate: NotificationCard {
                required property var modelData
                width: ListView.view.width
                notif: modelData
                onActed: popout.tray.closeAll()
            }

            add: Transition {
                NumberAnimation { property: "opacity"; from: 0; to: 1; duration: 200 }
                NumberAnimation {
                    property: "scale"
                    from: 0.97
                    to: 1
                    duration: 240
                    easing.type: Easing.OutBack
                }
            }

            remove: Transition {
                NumberAnimation { property: "opacity"; to: 0; duration: 150 }
                NumberAnimation {
                    property: "x"
                    to: 40
                    duration: 180
                    easing.type: Easing.InQuad
                }
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

    ColumnLayout {
        id: menuCol
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: 8
        anchors.topMargin: 8 + popout.tuck
        visible: opacity > 0
        enabled: popout.view === "menu"
        opacity: popout.view === "menu" ? 1 : 0
        transform: Translate {
            x: popout.view === "menu" ? 0 : 24
            Behavior on x { NumberAnimation { duration: 280; easing.type: Easing.OutBack; easing.overshoot: 1.2 } }
        }
        Behavior on opacity { NumberAnimation { duration: 150 } }
        spacing: 2

        Rectangle {
            Layout.fillWidth: true
            implicitHeight: 28
            radius: Theme.rounding
            color: backHover.containsMouse ? Theme.hover : "transparent"

            readonly property bool nested: popout.tray.menuStack.length > 0

            BarText {
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: 8
                text: parent.nested ? "\udb80\udf11 Back" : "\udb80\udf11 Tray"
                font.pixelSize: Theme.fontSizeSmall
            }

            MouseArea {
                id: backHover
                anchors.fill: parent
                hoverEnabled: true
                onClicked: parent.nested ? popout.tray.popMenu()
                                         : popout.tray.backToDrawer()
            }
        }

        Repeater {
            model: opener.children
            delegate: Rectangle {
                id: entry
                required property var modelData

                Layout.fillWidth: true
                implicitWidth: entryRow.implicitWidth + 16
                implicitHeight: modelData.isSeparator ? 10 : 28
                radius: Theme.rounding
                color: "transparent"
                opacity: modelData.enabled ? 1 : 0.45

                Rectangle {
                    visible: entry.modelData.isSeparator
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width
                    height: 1
                    color: Theme.overlay
                    opacity: 0.6
                }

                Rectangle {
                    visible: !entry.modelData.isSeparator
                    anchors.fill: parent
                    radius: Theme.rounding
                    color: hover.containsMouse ? Theme.hover : "transparent"

                    RowLayout {
                        id: entryRow
                        anchors.fill: parent
                        anchors.leftMargin: 8
                        anchors.rightMargin: 8
                        spacing: 8

                        BarText {
                            visible: entry.modelData.buttonType !== QsMenuButtonType.None
                            text: {
                                const checked = entry.modelData.checkState === Qt.Checked
                                return entry.modelData.buttonType === QsMenuButtonType.RadioButton
                                    ? (checked ? "\udb81\udc3e" : "\udb81\udc3d")
                                    : (checked ? "\udb80\udd32" : "\udb80\udd31")
                            }
                            color: entry.modelData.checkState === Qt.Checked
                                ? Theme.teal : Theme.overlay
                            font.pixelSize: Theme.fontSizeSmall
                        }

                        IconImage {
                            visible: entry.modelData.icon !== ""
                            Layout.preferredWidth: 16
                            Layout.preferredHeight: 16
                            source: entry.modelData.icon
                        }

                        BarText {
                            Layout.fillWidth: true
                            text: entry.modelData.text
                            font.pixelSize: Theme.fontSizeSmall
                            elide: Text.ElideRight
                        }

                        BarText {
                            visible: entry.modelData.hasChildren
                            text: "\u203a"
                            color: Theme.overlay
                            font.pixelSize: Theme.fontSizeSmall
                        }
                    }

                    MouseArea {
                        id: hover
                        anchors.fill: parent
                        hoverEnabled: true
                        enabled: entry.modelData.enabled && !entry.modelData.isSeparator
                        onClicked: {
                            if (entry.modelData.hasChildren) {
                                popout.tray.pushMenu(entry.modelData)
                            } else {
                                entry.modelData.triggered()
                                popout.tray.closeAll()
                            }
                        }
                    }
                }
            }
        }
    }
}

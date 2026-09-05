import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Widgets
import Quickshell.Hyprland

import qs.config
import qs.components
import qs.services as Services

Scope {
    id: root

    property bool opened: false
    property string filterText: ""
    property int selectedIndex: 0
    property bool cursorActive: true

    readonly property var rows: Services.Apps.revision >= 0 ? Services.Apps.search(root.filterText) : []
    readonly property int count: rows.length
    readonly property int visibleRows: Math.max(1, Math.min(count, Theme.launcherRows))

    function open() {
        root.filterText = ""
        root.selectedIndex = 0
        root.cursorActive = true
        pointerGate.reset()
        root.opened = true
    }

    function close() {
        root.opened = false
        root.filterText = ""
    }

    function toggle() {
        if (root.opened) root.close()
        else root.open()
    }

    function setFilter(next) {
        root.filterText = next
        root.selectedIndex = 0
        root.cursorActive = true
        pointerGate.reset()
        Qt.callLater(root.reveal)
    }

    function select(delta) {
        if (root.count === 0) return
        pointerGate.reset()
        const from = root.cursorActive ? root.selectedIndex + delta : (delta < 0 ? root.count - 1 : 0)
        root.selectedIndex = ((from % root.count) + root.count) % root.count
        root.cursorActive = true
        root.reveal()
    }

    function reveal() {
        if (root.count === 0) return
        list.positionViewAtIndex(Math.min(root.selectedIndex, root.count - 1), ListView.Contain)
    }

    function activate(index) {
        if (index < 0 || index >= root.count) return
        const entry = root.rows[index].entry
        root.close()
        Services.Apps.launch(entry)
    }

    function editsFilter(event) {
        if (!root.filterText) return false
        if (event.modifiers & (Qt.AltModifier | Qt.MetaModifier)) return false
        if (event.key === Qt.Key_U) return event.modifiers === Qt.ControlModifier
        return event.key === Qt.Key_Backspace
    }

    function editedFilter(event) {
        if (event.key === Qt.Key_U) return ""
        if (event.modifiers & Qt.ControlModifier) return root.filterText.replace(/\s+$/, "").replace(/\S+$/, "")
        return root.filterText.slice(0, -1)
    }

    function isPrintable(event) {
        if (!event.text || event.text.length !== 1) return false
        const code = event.text.charCodeAt(0)
        if (code < 32 || code === 127) return false
        const mods = event.modifiers & ~Qt.KeypadModifier
        return mods === Qt.NoModifier || mods === Qt.ShiftModifier
    }

    PointerMoveGate {
        id: pointerGate
        referenceItem: card
    }

    IpcHandler {
        target: "launcher"

        function toggle(): string {
            root.toggle()
            return root.opened ? "open" : "closed"
        }

        function open(): string {
            root.open()
            return "open"
        }

        function close(): string {
            root.close()
            return "closed"
        }
    }

    PanelWindow {
        id: win

        screen: Quickshell.screens.find(s => s.name === Hyprland.focusedMonitor?.name) ?? Quickshell.screens[0]
        visible: root.opened
        anchors { top: true; bottom: true; left: true; right: true }
        exclusionMode: ExclusionMode.Ignore
        color: "transparent"
        surfaceFormat.opaque: false

        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.namespace: "quickshell:launcher"
        WlrLayershell.keyboardFocus: root.opened ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

        onVisibleChanged: if (visible) keys.forceActiveFocus()

        Rectangle {
            anchors.fill: parent
            color: Theme.scrim
        }

        MouseArea {
            anchors.fill: parent
            onClicked: root.close()
        }

        readonly property int listHeight: root.visibleRows * Theme.launcherRowHeight
                                          + (root.visibleRows - 1) * list.spacing

        Rectangle {
            id: card

            width: Math.min(Theme.launcherWidth, win.width - 40)
            height: Theme.padding * 2 + header.height + Theme.spacing + 1 + Theme.spacing + win.listHeight
            x: Math.round((win.width - width) / 2)
            y: Math.round(win.height * 0.22)

            radius: Theme.popupRounding
            color: Theme.base
            border.width: 1
            border.color: Theme.overlay

            MouseArea { anchors.fill: parent }

            Item {
                id: keys
                anchors.fill: parent
                focus: true

                Keys.onPressed: (event) => {
                    const ctrl = event.modifiers & Qt.ControlModifier
                    if (event.key === Qt.Key_Escape) {
                        root.close()
                    } else if (root.editsFilter(event)) {
                        root.setFilter(root.editedFilter(event))
                    } else if (event.key === Qt.Key_Up || event.key === Qt.Key_Backtab
                               || (ctrl && (event.key === Qt.Key_K || event.key === Qt.Key_P))) {
                        root.select(-1)
                    } else if (event.key === Qt.Key_Down || event.key === Qt.Key_Tab
                               || (ctrl && (event.key === Qt.Key_J || event.key === Qt.Key_N))) {
                        root.select(1)
                    } else if (event.key === Qt.Key_PageUp) {
                        root.select(-6)
                    } else if (event.key === Qt.Key_PageDown) {
                        root.select(6)
                    } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                        root.activate(root.cursorActive ? root.selectedIndex : 0)
                    } else if (root.isPrintable(event)) {
                        root.setFilter(root.filterText + event.text)
                    } else {
                        return
                    }
                    event.accepted = true
                }
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: Theme.padding
                spacing: Theme.spacing

                RowLayout {
                    id: header
                    Layout.fillWidth: true
                    Layout.preferredHeight: 36
                    Layout.leftMargin: Theme.padding
                    Layout.rightMargin: Theme.padding
                    spacing: Theme.spacing + 2

                    BarText {
                        text: ""
                        color: Theme.mauve
                        font.pixelSize: Theme.fontSize
                    }

                    BarText {
                        Layout.fillWidth: true
                        text: root.filterText || "Search apps…"
                        color: root.filterText ? Theme.text : Theme.overlay
                        font.pixelSize: Theme.fontSize
                        elide: Text.ElideRight
                    }

                    BarText {
                        visible: root.filterText !== "" && root.count > 0
                        text: root.count
                        color: Theme.overlay
                        font.pixelSize: Theme.fontSizeSmall
                        tabular: true
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: 1
                    color: Theme.overlay
                    opacity: 0.4
                }

                Item {
                    Layout.fillWidth: true
                    Layout.preferredHeight: win.listHeight

                    ListView {
                        id: list
                        anchors.fill: parent
                        clip: true
                        spacing: 2
                        boundsBehavior: Flickable.StopAtBounds

                        model: ScriptModel {
                            values: root.rows.map(r => r.entry)
                        }

                        delegate: Rectangle {
                            id: row
                            required property int index
                            required property var modelData

                            readonly property bool hasCursor: root.cursorActive && row.index === root.selectedIndex

                            width: ListView.view.width
                            height: Theme.launcherRowHeight
                            radius: Theme.rounding
                            color: row.hasCursor ? Theme.surface0 : "transparent"

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: Theme.padding
                                anchors.rightMargin: Theme.padding
                                spacing: Theme.spacing + 2

                                IconImage {
                                    source: Services.Apps.iconFor(row.modelData)
                                    implicitSize: 26
                                    asynchronous: true
                                }

                                BarText {
                                    Layout.maximumWidth: Math.round(row.width * 0.62)
                                    text: Services.Apps.name(row.modelData)
                                    color: row.hasCursor ? Theme.text : Theme.subtext
                                    weight: row.hasCursor ? Font.Bold : Theme.fontWeight
                                    elide: Text.ElideRight
                                }

                                BarText {
                                    Layout.fillWidth: true
                                    text: Services.Apps.subtext(row.modelData)
                                    color: Theme.overlay
                                    font.pixelSize: Theme.fontSizeSmall
                                    horizontalAlignment: Text.AlignRight
                                    elide: Text.ElideRight
                                }
                            }

                            MouseArea {
                                id: rowMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onEntered: root.selectFromPointer(row.index, row, { x: rowMouse.mouseX, y: rowMouse.mouseY })
                                onPositionChanged: (mouse) => root.selectFromPointer(row.index, row, mouse)
                                onClicked: {
                                    root.cursorActive = true
                                    root.selectedIndex = row.index
                                    root.activate(row.index)
                                }
                            }
                        }
                    }

                    Rectangle {
                        anchors { left: parent.left; right: parent.right; top: parent.top }
                        height: Math.min(28, parent.height / 2)
                        visible: opacity > 0
                        opacity: list.contentHeight > list.height
                                 ? Math.max(0, Math.min(1, (list.contentY - list.originY) / height)) : 0
                        gradient: Gradient {
                            GradientStop { position: 0; color: Theme.base }
                            GradientStop { position: 1; color: Qt.rgba(Theme.base.r, Theme.base.g, Theme.base.b, 0) }
                        }
                    }

                    Rectangle {
                        anchors { left: parent.left; right: parent.right; bottom: parent.bottom }
                        height: Math.min(28, parent.height / 2)
                        visible: opacity > 0
                        opacity: list.contentHeight > list.height
                                 ? Math.max(0, Math.min(1, (list.originY + list.contentHeight - list.height - list.contentY) / height)) : 0
                        gradient: Gradient {
                            GradientStop { position: 0; color: Qt.rgba(Theme.base.r, Theme.base.g, Theme.base.b, 0) }
                            GradientStop { position: 1; color: Theme.base }
                        }
                    }

                    BarText {
                        anchors.centerIn: parent
                        visible: root.count === 0
                        text: root.filterText ? "No matches for “" + root.filterText + "”" : "No applications"
                        color: Theme.overlay
                        font.pixelSize: Theme.fontSizeSmall
                    }
                }
            }
        }
    }

    function selectFromPointer(index, item, mouse) {
        if (!pointerGate.moved(item, mouse)) return
        root.cursorActive = true
        root.selectedIndex = index
    }
}

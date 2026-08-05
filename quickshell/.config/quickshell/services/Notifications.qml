pragma Singleton

import Quickshell
import Quickshell.Services.Notifications
import QtQuick

Singleton {
    id: root

    property bool dnd: false
    property bool centerOpen: false

    property var list: []
    property var popups: []

    readonly property bool hasCritical: list.some(n => n.urgency === NotificationUrgency.Critical)

    property var _times: ({})
    property date now: new Date()

    onCenterOpenChanged: {
        if (centerOpen) {
            now = new Date()
            popups = []
        }
    }

    function timeoutFor(n) {
        if (n.urgency === NotificationUrgency.Critical)
            return n.transient ? 10000 : 0
        if (n.expireTimeout > 0)
            return n.expireTimeout
        return n.urgency === NotificationUrgency.Low ? 5000 : 10000
    }

    function hidePopup(n) {
        popups = popups.filter(p => p !== n)
        if (n.transient)
            n.dismiss()
    }

    function clearAll() {
        const pending = [...list]
        for (const n of pending)
            n.dismiss()
    }

    function ago(id) {
        const t = _times[id]
        if (!t)
            return ""
        const s = Math.max(0, Math.floor((now.getTime() - t) / 1000))
        if (s < 60) return "now"
        if (s < 3600) return Math.floor(s / 60) + "m"
        if (s < 86400) return Math.floor(s / 3600) + "h"
        return Math.floor(s / 86400) + "d"
    }

    function _adopt(n, fresh) {
        n.tracked = true
        _times[n.id] = Date.now()
        n.closed.connect(() => root._drop(n))

        if (!n.transient)
            list = [n, ...list]

        if (fresh && !dnd && !centerOpen)
            popups = [n, ...popups]
        else if (fresh && n.transient)
            Qt.callLater(() => n.dismiss())
    }

    function _drop(n) {
        popups = popups.filter(p => p !== n)
        list = list.filter(p => p !== n)
        delete _times[n.id]
    }

    readonly property var server: NotificationServer {
        keepOnReload: true
        actionsSupported: true
        bodySupported: true
        bodyMarkupSupported: true
        bodyHyperlinksSupported: true
        imageSupported: true
        persistenceSupported: true

        onNotification: (n) => root._adopt(n, true)
    }

    readonly property var _tick: Timer {
        interval: 30000
        running: root.centerOpen
        repeat: true
        onTriggered: root.now = new Date()
    }

    Component.onCompleted: {
        const vals = server.trackedNotifications.values
        for (const n of vals)
            _adopt(n, false)
    }
}

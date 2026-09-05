pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

import "AppSearch.js" as AppSearch

Singleton {
    id: root

    property string terminal: "ghostty"

    property int revision: 0

    property var _scanHidden: ({})
    property var _userHidden: ({})

    function isHidden(entry) {
        const id = String(entry?.id ?? "")
        return root._scanHidden[id] === true || root._userHidden[id] === true
    }

    function search(query) {
        return AppSearch.sortedEntries(DesktopEntries.applications.values, query, root.isHidden)
    }

    function name(entry) { return AppSearch.entryName(entry) }
    function subtext(entry) { return AppSearch.entrySubtext(entry) }

    function iconFor(entry) {
        const icon = String(entry?.icon ?? "")
        if (icon.startsWith("file://") || icon.startsWith("image://")) return icon
        if (icon.startsWith("/")) return "file://" + icon
        const themed = icon ? Quickshell.iconPath(icon, true) : ""
        return themed || Quickshell.iconPath("application-x-executable", true)
    }

    function launch(entry) {
        if (!entry) return
        if (entry.runInTerminal)
            Quickshell.execDetached([root.terminal, "-e"].concat([...entry.command]))
        else
            entry.execute()
    }

    function _parseIds(raw) {
        const out = ({})
        for (let line of String(raw || "").split("\n")) {
            line = line.trim()
            if (!line || line.startsWith("#")) continue
            if (line.endsWith(".desktop")) line = line.slice(0, -8)
            out[line] = true
        }
        return out
    }

    readonly property var _hides: FileView {
        path: Quickshell.shellDir + "/launcher/hides"
        watchChanges: true
        printErrors: false
        onLoaded: { root._userHidden = root._parseIds(text()); root.revision++ }
        onFileChanged: reload()
        onLoadFailed: { root._userHidden = ({}); root.revision++ }
    }

    readonly property var _scan: Process {
        command: ["bash", Quickshell.shellDir + "/scripts/hidden-entries.sh",
                  [Quickshell.env("XDG_CURRENT_DESKTOP"), Quickshell.env("XDG_SESSION_DESKTOP")]
                      .filter(v => v).join(":")]
        stdout: StdioCollector {
            onStreamFinished: { root._scanHidden = root._parseIds(text); root.revision++ }
        }
    }

    readonly property var _rescan: Timer {
        interval: 750
        onTriggered: if (!root._scan.running) root._scan.running = true
    }

    readonly property var _watch: Connections {
        target: DesktopEntries.applications
        function onValuesChanged() { root._rescan.restart(); root.revision++ }
    }

    Component.onCompleted: _scan.running = true
}

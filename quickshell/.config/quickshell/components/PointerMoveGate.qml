import QtQuick

QtObject {
    id: root

    property Item referenceItem: null
    property real threshold: 1
    property bool primed: false
    property bool initialSampleAllowed: false
    property real lastX: 0
    property real lastY: 0

    function reset() {
        root.primed = false
        root.initialSampleAllowed = false
        root.lastX = 0
        root.lastY = 0
    }

    function allowInitialSample() {
        root.reset()
        root.initialSampleAllowed = true
    }

    function moved(item, mouse) {
        if (!item || !mouse) {
            root.reset()
            return false
        }

        const target = root.referenceItem || item
        const point = item.mapToItem(target, mouse.x, mouse.y)
        const firstSample = !root.primed
        const didMove = !firstSample
            ? Math.abs(point.x - root.lastX) > root.threshold || Math.abs(point.y - root.lastY) > root.threshold
            : root.initialSampleAllowed

        if (firstSample || didMove) {
            root.lastX = point.x
            root.lastY = point.y
        }
        root.primed = true
        root.initialSampleAllowed = false

        return didMove
    }
}

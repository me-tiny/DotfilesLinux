import QtQuick

import qs.config

Text {
    id: root

    property bool tabular: false
    property int weight: Theme.fontWeight
    property int grade: Theme.fontGrade
    property var extraFeatures: ({})

    textFormat: Text.PlainText
    color: Theme.text
    font.family: Theme.fontFamily
    font.pixelSize: Theme.fontSize

    font.weight: root.weight
    font.variableAxes: ({ "wght": root.weight, "GRAD": root.grade })

    font.features: {
        const f = Object.assign({}, Theme.fontFeatures, root.extraFeatures)
        if (root.tabular)
            f["tnum"] = 1

        return f
    }
}

pragma Singleton

import Quickshell
import QtQuick

Singleton {
    readonly property color base:    "#1e1e2e"
    readonly property color surface0: "#313244"
    readonly property color surface1: "#45475a"
    readonly property color text:    "#cdd6f4"
    readonly property color subtext: "#a6adc8"
    readonly property color overlay: "#6c7086"
    readonly property color teal:    "#94e2d5"
    readonly property color mauve:   "#cba6f7"
    readonly property color red:     "#f38ba8"
    readonly property color yellow:  "#f9e2af"
    readonly property color blue:    "#89b4fa"
    readonly property color green:   "#a6e3a1"

    readonly property string fontFamily: "MonoLisaText"
    readonly property int fontSize: 18
    readonly property int fontSizeSmall: fontSize - 2
    readonly property int fontSizeIcon: fontSize + 6

    readonly property int fontWeight: Font.DemiBold
    readonly property int fontGrade: 0

    readonly property var fontFeatures: ({
        "calt": 1,
        "liga": 0,
        "dlig": 0,
    })

    readonly property int barHeight: 32
    readonly property int padding: 8
    readonly property int spacing: 8

    readonly property color hover: Qt.rgba(1, 1, 1, 0.06)
    readonly property int rounding: 6
    readonly property int popupRounding: 10

    readonly property int popupAnimMs: 180
    readonly property int popoutSpace: 600

    readonly property color scrim: Qt.rgba(0, 0, 0, 0.45)
    readonly property int launcherWidth: 640
    readonly property int launcherRows: 10
    readonly property int launcherRowHeight: 44
}

import Quickshell

import qs.bar as Bar
import qs.launcher as Launcher

ShellRoot {
    Variants {
        model: Quickshell.screens
        Bar.Bar { }
    }

    Bar.NotificationPopups { }
    Launcher.Launcher { }
}

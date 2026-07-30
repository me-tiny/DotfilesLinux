hl.workspace_rule({ workspace = "1", monitor = "DP-3", default = true })
hl.workspace_rule({ workspace = "2", monitor = "DP-3" })
hl.workspace_rule({ workspace = "3", monitor = "DP-3" })
hl.workspace_rule({ workspace = "4", monitor = "DP-3" })
hl.workspace_rule({ workspace = "5", monitor = "DP-3" })
hl.workspace_rule({ workspace = "6", monitor = "DP-3" })

hl.workspace_rule({ workspace = "7", monitor = "DP-4", default = true })
hl.workspace_rule({ workspace = "8", monitor = "DP-4" })
hl.workspace_rule({ workspace = "9", monitor = "DP-4" })
hl.workspace_rule({ workspace = "10", monitor = "DP-4" })

hl.window_rule({
    name = "suppress-maximise-events",
    match = { class = ".*" },
    suppress_event = "maximize",
})

hl.window_rule({
    name = "fix-xwayland-drags",
    match = {
        class = "^$",
        title = "^$",
        xwayland = true,
        float = true,
        fullscreen = false,
        pin = false,
    },
    no_focus = true,
})

hl.window_rule({
    name = "xwaylandvideobridge-for-screenshare",
    match = {
        class = "^(xwaylandvideobridge)$",
    },
    opacity = "0.0 override",
    no_anim = true,
    no_focus = true,
    no_initial_focus = true,
    max_size = { 1, 1 },
    no_blur = true,
})

hl.window_rule({
    name = "steam-in-workspace-4",
    match = {
        title = "^.+$",
        class = "^(steam)$",
    },
    workspace = "4 silent",
})

hl.window_rule({
    name = "steam-floats",
    match = {
        title = "^()$",
        class = "^(steam)$",
    },
    stay_focused = true,
    min_size = { 1, 1 },
})

hl.window_rule({
    name = "spotify-in-workspace-7",
    match = {
        class = "^(spotify)$",
    },
    workspace = "7 silent",
})

hl.window_rule({
    name = "discord-in-workspace-7",
    match = {
        class = "^(discord)$",
    },
    workspace = "7 silent",
})

hl.window_rule({
    name = "runelite-main-float",
    match = {
        class = "^(net-runelite-launcher-Launcher)$",
        title = "^(RuneLite)$",
    },
    float = true,
    size = { 1532, 844 },
})

hl.window_rule({
    name = "runelite-no-float-focus",
    match = {
        class = "^(net-runelite-launcher-Launcher)$",
        title = "^(win(.*))$",
    },
    no_initial_focus = true,
    no_focus = true,
})

hl.window_rule({
    name = "runelite-launcher-float",
    match = {
        class = "^(net-runelite-(client-RuneLite|launcher-Launcher))$",
        title = "^(RuneLite Launcher)$",
    },
    float = true,
    no_initial_focus = true,
})

hl.window_rule({
    name = "zoom-float-default",
    match = {
        class = "^(zoom)$",
    },
    float = true,
})

hl.window_rule({
    name = "zoom-tile-primary",
    match = {
        class = "^(zoom)$",
        title = "^(Zoom Workplace|Zoom Meeting|Meeting|Zoom Cloud Meetings)$",
    },
    tile = true,
    idle_inhibit = "always",
})

hl.window_rule({
    name = "zoom-toasts",
    match = {
        class = "^(zoom)$",
        title = "^(zoom)$",
    },
    no_focus = true,
    no_initial_focus = true,
    no_anim = true,
    no_blur = true,
    no_shadow = true,
})

hl.window_rule({
    name = "zoom-popups-stay-focused",
    match = {
        class = "^(zoom)$",
        title = "^(menu window|confirm window)$",
    },
    stay_focused = true,
    no_anim = true,
})

hl.window_rule({
    name = "zoom-screenshare-chrome",
    match = {
        class = "^(zoom)$",
        title = "^([a-z_]+_toolbar|zoom_linux_float_video_window)$",
    },
    pin = true,
    no_focus = true,
    no_initial_focus = true,
})

hl.window_rule({
    name = "godot-float",
    match = {
        class = "org.godotengine.Editor",
    },
    float = true,
})

hl.window_rule({
    name = "godot-tile",
    match = {
        class = "org.godotengine.Editor",
        initial_title = "^Godot$",
    },
    tile = true,
})

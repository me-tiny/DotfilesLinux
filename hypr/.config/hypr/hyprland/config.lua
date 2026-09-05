local color = require("hyprland.colors")
hl.config({
    input = {
        repeat_rate = 50,
        repeat_delay = 200,
        follow_mouse = 2,
        force_no_accel = true,
        accel_profile = "flat",
        sensitivity = 0.0,
        float_switch_override_focus = 0,
        numlock_by_default = true,
    },
    cursor = {
        no_hardware_cursors = 0,
        default_monitor = "DP-3",
        hide_on_key_press = true,
    },
    general = {
        gaps_in = 0,
        gaps_out = 0,
        border_size = 2,
        allow_tearing = false,
        layout = "dwindle",
        col = {
            active_border = color.blue,
            inactive_border = color.base,
        },
    },
    decoration = {
        rounding = 0,
        active_opacity = 1.0,
        inactive_opacity = 1.0,
        shadow = {
            enabled = false,
        },
        blur = {
            enabled = false,
        },
    },
    debug = {
        overlay = false,
        disable_logs = true,
        vfr = false,
    },
    animations = {
        enabled = false,
    },
    dwindle = {
        preserve_split = true,
        smart_split = false,
        smart_resizing = false,
    },
    master = {
        new_status = "slave",
        mfact = 0.50,
        orientation = "right",
    },
    misc = {
        vrr = 1,
        force_default_wallpaper = 0,
        disable_hyprland_logo = true,
        disable_splash_rendering = true,
        middle_click_paste = false,
        mouse_move_enables_dpms = true,
        mouse_move_focuses_monitor = false,
        key_press_enables_dpms = true,
        disable_scale_notification = true,
        allow_session_lock_restore = true,
    },
    xwayland = {
        force_zero_scaling = true,
    },
    binds = {
        hide_special_on_workspace_change = true,
    },
    ecosystem = {
        no_update_news = true,
    },
})

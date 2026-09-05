local terminal = "ghostty"
local file_manager = "thunar"
local menu = "rofi -modi drun, run -show drun"
local launcher = "qs ipc call launcher toggle"
local notifs = "qs ipc call notifs"
local calc =
    "rofi -show calc -no-show-match -no-sort -automatic-save-to-history -lines 0 -calc-command 'echo -n '{result}' | wl-copy'"
local emoji = "rofi -show emoji -kb-accept-entry '' -kb-custom-1 Return"
local clipboard = "cliphist list | rofi -dmenu -display-columns 2 | cliphist decode | wl-copy"
local lock = "hyprlock"
local color_picker = "hyprpicker -a"
local music_player = "playerctl -p spotify"
local screenshot = "hyprshot -z -m region"

local main_mod = "SUPER"

hl.bind(main_mod .. " + RETURN", hl.dsp.exec_cmd(terminal))
hl.bind(main_mod .. " + Q", hl.dsp.window.close())
hl.bind(main_mod .. " + E", hl.dsp.exec_cmd(file_manager))
hl.bind(main_mod .. " + SHIFT + SPACE", hl.dsp.window.float({ action = "toggle" }))
hl.bind(main_mod .. " + F", hl.dsp.window.fullscreen({ mode = "maximized", action = "toggle" }))
hl.bind(main_mod .. " + SHIFT + F", hl.dsp.window.fullscreen({ mode = "fullscreen", action = "toggle" }))
hl.bind(main_mod .. " + D", hl.dsp.exec_cmd(launcher))
hl.bind(main_mod .. " + SHIFT + D", hl.dsp.exec_cmd(menu))
hl.bind(main_mod .. " + SHIFT + E", hl.dsp.exec_cmd(emoji))
hl.bind(main_mod .. " + C", hl.dsp.exec_cmd(calc))
hl.bind(main_mod .. " + P", hl.dsp.window.pseudo({ action = "toggle" }))
hl.bind(main_mod .. " + A", hl.dsp.layout("togglesplit"))
hl.bind(main_mod .. " + ALT + L", hl.dsp.exec_cmd(lock))
hl.bind(main_mod .. " + SHIFT + C", hl.dsp.exec_cmd(color_picker))
hl.bind(main_mod .. " + V", hl.dsp.exec_cmd(clipboard))
hl.bind("CTRL + SHIFT + 4", hl.dsp.exec_cmd(screenshot))
hl.bind(main_mod .. " + SHIFT + I", hl.dsp.exec_cmd("togidle"))
hl.bind(main_mod .. " + SHIFT + P", hl.dsp.exec_cmd("1password --quick-access"))
hl.bind(main_mod .. " + comma", hl.dsp.exec_cmd(notifs .. " dismiss"))
hl.bind(main_mod .. " + SHIFT + comma", hl.dsp.exec_cmd(notifs .. " dismissAll"))
hl.bind(main_mod .. " + CTRL + comma", hl.dsp.exec_cmd(notifs .. " toggleDnd"))
hl.bind(main_mod .. " + ALT + comma", hl.dsp.exec_cmd(notifs .. " invokeLast"))
hl.bind(main_mod .. " + O", hl.dsp.exec_cmd("hyprpop"))

hl.bind("XF86AudioPlay", hl.dsp.exec_cmd(music_player .. " play-pause"))
hl.bind("XF86AudioNext", hl.dsp.exec_cmd(music_player .. " next"))
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd(music_player .. " previous"))

hl.bind(main_mod .. " + LEFT", hl.dsp.focus({ direction = "left" }))
hl.bind(main_mod .. " + DOWN", hl.dsp.focus({ direction = "down" }))
hl.bind(main_mod .. " + UP", hl.dsp.focus({ direction = "up" }))
hl.bind(main_mod .. " + RIGHT", hl.dsp.focus({ direction = "right" }))

hl.bind(main_mod .. " + H", hl.dsp.focus({ direction = "left" }))
hl.bind(main_mod .. " + J", hl.dsp.focus({ direction = "down" }))
hl.bind(main_mod .. " + K", hl.dsp.focus({ direction = "up" }))
hl.bind(main_mod .. " + L", hl.dsp.focus({ direction = "right" }))

hl.bind(main_mod .. " + SHIFT + LEFT", hl.dsp.window.move({ direction = "left" }))
hl.bind(main_mod .. " + SHIFT + DOWN", hl.dsp.window.move({ direction = "down" }))
hl.bind(main_mod .. " + SHIFT + UP", hl.dsp.window.move({ direction = "up" }))
hl.bind(main_mod .. " + SHIFT + RIGHT", hl.dsp.window.move({ direction = "right" }))

hl.bind(main_mod .. " + SHIFT + H", hl.dsp.window.move({ direction = "left" }))
hl.bind(main_mod .. " + SHIFT + J", hl.dsp.window.move({ direction = "down" }))
hl.bind(main_mod .. " + SHIFT + K", hl.dsp.window.move({ direction = "up" }))
hl.bind(main_mod .. " + SHIFT + L", hl.dsp.window.move({ direction = "right" }))

for i = 1, 10 do
    local key = i % 10
    hl.bind(main_mod .. " + " .. key, hl.dsp.focus({ workspace = i }))
    hl.bind(main_mod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

hl.bind(main_mod .. " + TAB", hl.dsp.focus({ workspace = "m+1" }))
hl.bind(main_mod .. " + SHIFT + TAB", hl.dsp.focus({ workspace = "m-1" }))

hl.bind(main_mod .. " + S", hl.dsp.workspace.toggle_special("magic"))
hl.bind(main_mod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))

hl.bind(main_mod .. "+ mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(main_mod .. "+ mouse:273", hl.dsp.window.resize(), { mouse = true })

hl.bind(main_mod .. " + R", hl.dsp.submap("resize"))
hl.define_submap("resize", function()
    hl.bind("LEFT", hl.dsp.window.resize({ x = -20, y = 0, relative = true }), { repeating = true })
    hl.bind("DOWN", hl.dsp.window.resize({ x = 0, y = 20, relative = true }), { repeating = true })
    hl.bind("UP", hl.dsp.window.resize({ x = 0, y = -20, relative = true }), { repeating = true })
    hl.bind("RIGHT", hl.dsp.window.resize({ x = 20, y = 0, relative = true }), { repeating = true })

    hl.bind("H", hl.dsp.window.resize({ x = -20, y = 0, relative = true }), { repeating = true })
    hl.bind("J", hl.dsp.window.resize({ x = 0, y = 20, relative = true }), { repeating = true })
    hl.bind("K", hl.dsp.window.resize({ x = 0, y = -20, relative = true }), { repeating = true })
    hl.bind("L", hl.dsp.window.resize({ x = 20, y = 0, relative = true }), { repeating = true })

    hl.bind("ESCAPE", hl.dsp.submap("reset"))
    hl.bind(main_mod .. " + R", hl.dsp.submap("reset"))
end)

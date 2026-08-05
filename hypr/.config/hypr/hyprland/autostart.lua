hl.on("hyprland.start", function()
    local autostart = {
        "dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP",
        "dbus-update-activation-environment --systemd --all",
        "systemctl --user import-environment $(env | cut -d'=' -f 1)",
        "systemctl --user start hyprland-session.target",
        "easyeffects --gapplication-service",
        "gsettings set org.gnome.desktop.interface gtk-theme 'adw-gtk3-dark'",
        "gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'",
        "wl-paste --type text --watch cliphist store",
        "wl-paste --type image --watch cliphist store",
        "wl-clip-persist --clipboard regular",
        "systemctl --user start hyprpolkitagent",
        "1password --silent",
        "thunar --daemon",
        "wlsunset -l -33.9 -L 151.2",
        "qs & hyprpaper & hypridle",
        "[workspace 1 silent] ghostty",
        "[workspace 1 silent] zen-browser",
        "[workspace 7 silent] sh -c 'until getent hosts spclient.wg.spotify.com >/dev/null; do sleep 0.5; done; spotify-launcher'",
        "[workspace 7 silent] discord",
    }

    for _, cmd in ipairs(autostart) do
        hl.exec_cmd(cmd)
    end
end)

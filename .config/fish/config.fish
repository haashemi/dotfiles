if status is-interactive
    # Commands to run in interactive sessions can go here
end

if status is-login; and test -z "$WAYLAND_DISPLAY"; and test (tty) = /dev/tty1
    exec niri-session -l
end

# opencode
fish_add_path /home/ali/.opencode/bin

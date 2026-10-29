#!/bin/sh
# Clipboard history store behind SClipboard.
#
# Entries are files named <epoch-ns>-<sha1>.<ext> ("txt" for text, otherwise the
# image subtype), so names sort by copy time and duplicates are found by content.
# history/ keeps the newest $max; pinned/ is never trimmed.
#
#   store           wl-paste --watch callback: save the current selection, print "changed"
#   list            print entry paths, pinned first, newest first
#   copy <path>     put an entry back on the clipboard
#   pin|unpin <path>, delete <path>, clear (history only)
#
# pin, unpin, delete and clear end by printing the list.

set -eu

dir="${XDG_DATA_HOME:-$HOME/.local/share}/aurora/clipboard"
max=14
mkdir -p "$dir/history" "$dir/pinned"

list() {
    ls -1 "$dir/pinned" | sort -r | sed "s|^|$dir/pinned/|"
    ls -1 "$dir/history" | sort -r | sed "s|^|$dir/history/|"
}

trim() {
    ls -1 "$dir/history" | sort -r | tail -n +$((max + 1)) | while read -r f; do
        rm -f "$dir/history/$f"
    done
}

store() {
    # Password managers mark their copies sensitive; never keep those.
    [ "${CLIPBOARD_STATE:-data}" = data ] || exit 0
    # stdin holds whatever type wl-paste guessed (often text/html for copied
    # images), so pick the type ourselves.
    exec </dev/null
    types=$(wl-paste --list-types) || exit 0
    if printf '%s\n' "$types" | grep -qE '^(text/plain|UTF8_STRING|STRING|TEXT)'; then
        type=text
        ext=txt
    elif type=$(printf '%s\n' "$types" | grep -m1 '^image/'); then
        ext=${type#image/}
        ext=${ext%%[;+]*}
    else
        exit 0
    fi

    tmp=$(mktemp "$dir/.new.XXXXXX")
    if ! wl-paste --no-newline --type "$type" >"$tmp" || [ ! -s "$tmp" ]; then
        rm -f "$tmp"
        exit 0
    fi
    sum=$(sha1sum <"$tmp" | cut -c1-40)

    # Pinned copies stay where they are; history copies move to the top.
    if [ -n "$(find "$dir/pinned" -name "*-$sum.*")" ]; then
        rm -f "$tmp"
    else
        find "$dir/history" -name "*-$sum.*" -delete
        mv "$tmp" "$dir/history/$(date +%s%N)-$sum.$ext"
        trim
    fi
    echo changed
}

case "${1:-}" in
store) store ;;
list) list ;;
copy)
    case "$2" in
    *.txt) wl-copy <"$2" ;;
    *) wl-copy --type "image/${2##*.}" <"$2" ;;
    esac >/dev/null 2>&1
    ;;
pin)
    mv "$2" "$dir/pinned/"
    list
    ;;
unpin)
    # Back on top of the history, so trimming doesn't drop it right away.
    name=$(basename "$2")
    mv "$2" "$dir/history/$(date +%s%N)-${name#*-}"
    trim
    list
    ;;
delete)
    rm -f "$2"
    list
    ;;
clear)
    find "$dir/history" -type f -delete
    list
    ;;
*)
    echo "usage: $0 store|list|copy|pin|unpin|delete|clear [path]" >&2
    exit 1
    ;;
esac

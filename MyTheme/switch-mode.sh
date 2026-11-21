#!/usr/bin/env bash
# Switch MyTheme between its dark and light variants for GTK2, GTK3 and GTK4.
#
# Usage: switch-mode.sh [dark|light]
#
# Per toolkit this activates the chosen variant inside the theme directory,
# refreshes the per-user stylesheet in $XDG_CONFIG_HOME (default ~/.config) and
# sets gtk-application-prefer-dark-theme in settings.ini. Run it again after
# updating the theme so the installed per-user copies do not go stale.
set -euo pipefail

usage() {
    echo "Usage: ${0##*/} [dark|light]" >&2
    exit 2
}

[ "$#" -eq 1 ] || usage
mode=$1
case "$mode" in
    dark)  pref=1 ;;
    light) pref=0 ;;
    *)     usage ;;
esac

# The theme directory is the one this script lives in (symlinks resolved), so
# it works from ~/.themes/MyTheme and from a repository checkout alike.
script=$(readlink -f -- "${BASH_SOURCE[0]}")
theme=${script%/*}
config=${XDG_CONFIG_HOME:-$HOME/.config}

# Check every input first so a missing file cannot leave a half-switched theme.
for src in \
    "$theme/gtk-2.0/gtkrc-$mode" \
    "$theme/gtk-3.0/gtk-$mode.css" \
    "$theme/gtk-4.0/gtk-$mode.css"; do
    [ -r "$src" ] || { echo "error: missing $src" >&2; exit 1; }
done

tmp=
trap '[ -z "$tmp" ] || rm -f -- "$tmp"' EXIT

# Copy SRC over DEST unless they are the same file (e.g. a symlinked dotfile).
install_file() {
    if [ "$1" -ef "$2" ]; then
        return 0
    fi
    cp -- "$1" "$2"
}

# Set gtk-application-prefer-dark-theme=VALUE inside the [Settings] section of
# INI, adding the key (or the section) if needed. The result is written through
# the existing file, so a symlinked settings.ini stays a symlink.
set_prefer_dark() {
    local ini=$1 value=$2
    tmp=$(mktemp)
    awk -v value="$value" '
        BEGIN { key = "gtk-application-prefer-dark-theme" }
        /^\[.*\]/ {
            if (in_settings && !done) { print key "=" value; done = 1 }
            in_settings = ($0 == "[Settings]")
            if (in_settings) have_section = 1
        }
        in_settings && index($0, key "=") == 1 { print key "=" value; done = 1; next }
        { print }
        END {
            if (!done) {
                if (!have_section) print "[Settings]"
                print key "=" value
            }
        }
    ' "$ini" > "$tmp"
    cat -- "$tmp" > "$ini"
    rm -f -- "$tmp"
    tmp=
}

for v in gtk-3.0 gtk-4.0; do
    mkdir -p -- "$config/$v"
    install_file "$theme/$v/gtk-$mode.css" "$theme/$v/gtk.css"
    install_file "$theme/$v/gtk-$mode.css" "$config/$v/gtk.css"

    ini=$config/$v/settings.ini
    if [ ! -e "$ini" ]; then
        if [ -r "$theme/user-config/$v/settings.ini" ]; then
            cp -- "$theme/user-config/$v/settings.ini" "$ini"
        else
            : > "$ini"
        fi
    fi
    set_prefer_dark "$ini" "$pref"
done

install_file "$theme/gtk-2.0/gtkrc-$mode" "$theme/gtk-2.0/gtkrc"

echo "MyTheme switched to $mode. Restart GTK applications (or log out/in) to apply everywhere."

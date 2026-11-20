#!/usr/bin/env bash
# Switch MyTheme between its dark and light variants for GTK2, GTK3 and GTK4.
# Usage: ~/.themes/MyTheme/switch-mode.sh [dark|light]
set -euo pipefail

mode="${1:-}"
case "$mode" in
    dark|light) ;;
    *) echo "Usage: $0 [dark|light]" >&2; exit 2 ;;
esac

theme="$HOME/.themes/MyTheme"
config="$HOME/.config"

for v in gtk-3.0 gtk-4.0; do
    cp "$theme/$v/gtk-$mode.css" "$theme/$v/gtk.css"
    cp "$theme/$v/gtk-$mode.css" "$config/$v/gtk.css"

    ini="$config/$v/settings.ini"
    pref=1
    [ "$mode" = "light" ] && pref=0
    if grep -q '^gtk-application-prefer-dark-theme=' "$ini"; then
        sed -i "s/^gtk-application-prefer-dark-theme=.*/gtk-application-prefer-dark-theme=$pref/" "$ini"
    else
        printf 'gtk-application-prefer-dark-theme=%s\n' "$pref" >> "$ini"
    fi
done

cp "$theme/gtk-2.0/gtkrc-$mode" "$theme/gtk-2.0/gtkrc"

echo "MyTheme switched to $mode. Restart GTK applications (or log out/in) to apply everywhere."

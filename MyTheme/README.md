# MyTheme

A modern GTK2 / GTK3 / GTK4 theme. The dark palette is VS Code Dark+ inspired
and keeps the requested `#101113` window base; the light variant is a
colour-remapped companion using the same widget rules.

## Files

| Path | Purpose |
| --- | --- |
| `~/.gtkrc-2.0` | GTK2 settings (`gtk-theme-name`, `gtk-icon-theme-name`, …) |
| `~/.config/gtk-3.0/settings.ini` | GTK3 settings |
| `~/.config/gtk-3.0/gtk.css` | GTK3 active stylesheet |
| `~/.config/gtk-4.0/settings.ini` | GTK4 settings |
| `~/.config/gtk-4.0/gtk.css` | GTK4 active stylesheet |
| `~/.themes/MyTheme/gtk-2.0/gtkrc` | GTK2 theme definition |
| `~/.themes/MyTheme/gtk-3.0/gtk.css` | GTK3 theme stylesheet |
| `~/.themes/MyTheme/gtk-4.0/gtk.css` | GTK4 theme stylesheet |

Each GTK3/GTK4 theme directory also contains `gtk-dark.css` and `gtk-light.css`.

## Spacing

Side panes use a 1px right border and a 1px `paned > separator` handle.
Sidebar rows have 8px/9px vertical padding (26px/28px minimum height), and
other list/rows use 7px/8px vertical padding (24px/26px minimum height).
GTK2 tree panes use `ythickness = 4`. Rectangular widgets use 2px corners;
circular controls (radio buttons, sliders, switches, `.circular`) keep 50%.
Scrollbars are thin (4px) VS Code style with a transparent trough.
Status bars have no box: GTK3/GTK4 use transparent, borderless `.statusbar`
with a single 1px line above it, and GTK2 sets
`GtkStatusbar::shadow-type = GTK_SHADOW_NONE`.

PCManFM (GTK3) puts its free-space label inside a `GtkFrame` in the statusbar.
GTK3's `GtkStatusbar` has no `.statusbar` CSS class, so the theme targets it
with the element selector `statusbar frame > border` to remove that box.

## Dark / light mode

GTK applications prefer dark mode via `gtk-application-prefer-dark-theme=1`
in the `settings.ini` files. To switch every toolkit at once:

```sh
~/.themes/MyTheme/switch-mode.sh light   # or: dark
```

Then restart running GTK applications (GTK2/GTK3 do not hot-reload `settings.ini`;
GTK4 applications may need a restart too).

Manual switching: copy `gtk-light.css` over `gtk.css` in
`~/.config/gtk-3.0/` and `~/.config/gtk-4.0/`, set
`gtk-application-prefer-dark-theme=0`, and copy `gtk-2.0/gtkrc-light` over
`gtk-2.0/gtkrc`.

## Brave / Chromium tab separator

Brave with GTK theming enabled draws its tab strip through `GtkNotebook`, so
the theme adds a 1px `border-left` between adjacent tabs using
`@my_border_soft`. The rule is scoped to
`window.background.chromium notebook > header > tabs > tab`, so native GTK
notebooks are unaffected. It is present in every GTK3/GTK4 stylesheet variant
and in the installed copies under `~/.themes/MyTheme` and `~/.config`.

Restart Brave to apply.

## Palette

The dark palette is VS Code Dark+ inspired while retaining the requested
`#101113` window base.

| Role | Dark | Light |
| --- | --- | --- |
| Base / window | `#101113` | `#f6f7f8` |
| Sidebar surface | `#121314` | `#ffffff` |
| Raised surface | `#252526` | `#eef0f2` |
| Hover surface | `#2a2d2e` | `#e3e6ea` |
| Border | `#3c3c3c` | `#d3d6db` |
| Soft border | `#2b2b2b` | `#e6e8eb` |
| Foreground | `#d4d4d4` | `#202124` |
| Muted foreground | `#858585` | `#5f6368` |
| Accent | `#007acc` | `#005a9e` |
| Selection | `#264f78` | `rgba(0,122,204,0.18)` |
| Success / warning / error | `#4ec9b0` / `#cca700` / `#f14c4c` | `#00796b` / `#9a6700` / `#c5221f` |

Previous configuration files were preserved as `*.bak.<timestamp>` next to
their originals. `~/.config/gtk-4.0/assets` still points at the previously
used `Fluent-Dark` theme; MyTheme does not reference it, so it is harmless.

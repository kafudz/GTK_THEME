# MyTheme

A minimal GTK2 / GTK3 / GTK4 theme with a dark and a light variant. Both
variants share the same widget rules; only colour values differ.

## Layout

| Path | Purpose |
| --- | --- |
| `gtk-2.0/gtkrc-dark`, `gtkrc-light` | GTK2 variants |
| `gtk-2.0/gtkrc` | GTK2 active copy (the only file GTK2 reads) |
| `gtk-3.0/gtk-dark.css`, `gtk-light.css` | GTK3 variants |
| `gtk-3.0/gtk.css` | GTK3 active copy |
| `gtk-4.0/gtk-dark.css`, `gtk-light.css` | GTK4 variants |
| `gtk-4.0/gtk.css` | GTK4 active copy |
| `index.theme` | Theme metadata |
| `switch-mode.sh` | Activates a variant and installs the per-user files |
| `user-config/` | Templates: `.gtkrc-2.0`, `gtk-3.0/settings.ini`, `gtk-4.0/settings.ini` |

`gtk.css` and `gtkrc` are copies of the active variant and are rewritten by
`switch-mode.sh`; edit the `-dark` / `-light` files instead. The committed
default is dark. GTK3/GTK4 also load `gtk-dark.css` on their own when
`gtk-application-prefer-dark-theme=1`.

## Install

1. Copy or symlink this directory to `~/.themes/MyTheme`.
2. Run `~/.themes/MyTheme/switch-mode.sh dark` (or `light`).
3. Optional: copy `user-config/.gtkrc-2.0` to `~/.gtkrc-2.0`. It is an
   `nwg-look` export; its `include` line points at the author's home directory
   and must be adapted.

`switch-mode.sh` copies the chosen variant to the theme's `gtk.css` / `gtkrc`,
installs `gtk.css` into `~/.config/gtk-3.0` and `~/.config/gtk-4.0` (libadwaita
apps ignore the theme name and read GTK4 CSS from there), creates
`settings.ini` from the templates if missing, and sets
`gtk-application-prefer-dark-theme`. It honours `XDG_CONFIG_HOME`, checks every
input before changing anything, and is safe to re-run.

**Re-run it after every theme update.** The per-user `gtk.css` is loaded on top
of the theme and silently overrides it, so a stale copy hides fixes.

Restart running GTK applications afterwards; GTK2/GTK3 do not hot-reload
`settings.ini`.

## Arch Linux

`PKGBUILD` (repository root) builds `mytheme-gtk-theme-git`:

```sh
makepkg -si
```

It installs two themes into `/usr/share/themes`: `MyTheme` (dark) and
`MyTheme-Light`. Select one by name (`gtk-theme-name=MyTheme-Light` in
`settings.ini`, or with `nwg-look`); no switching script is needed and the
package never writes into your home directory. libadwaita apps ignore the theme
name, so for those copy the stylesheet yourself, e.g.
`cp /usr/share/themes/MyTheme/gtk-4.0/gtk.css ~/.config/gtk-4.0/gtk.css`.
Settings templates are in `/usr/share/doc/mytheme-gtk-theme-git/examples/`.

`switch-mode.sh` is not packaged: it writes into the theme directory, which is
read-only under `/usr`. A copy in `~/.themes/MyTheme` takes precedence over the
system theme of the same name.

`makepkg` clones the GitHub repository, so it packages what has been pushed,
not local uncommitted changes.

## Design notes

- Rectangular widgets use 2px corners; sliders, radio buttons and
  `.circular` buttons are round.
- Scrollbars are thin (4px) with a transparent trough and no arrow buttons.
- Paned handles are a single 1px line; the dotted grip is removed.
- Toolbars get a 1px line below them. PCManFM puts its toolbar and address bar
  in one row, which the fork tags with the `toolbar-row` style class, so the
  theme draws a single line across the whole row. With a PCManFM build that
  lacks the class, only the toolbar part gets the line.
- Row spacing: GTK3 rows use 6px/8px padding (sidebar rows 7px/8px); GTK4 rows
  use 8px/12px (sidebar rows 9px/12px). GTK2 tree views use `ythickness = 4`.
- Status bars are a surface-coloured bar with a 1px top border. PCManFM (GTK3)
  puts its free-space label in a `GtkFrame` inside the status bar; GTK3's
  `GtkStatusbar` has no `.statusbar` class, so the theme uses the element
  selector `statusbar frame > border` to remove that box.
- Brave/Chromium with GTK theming draws its tab strip through `GtkNotebook`, so
  adjacent tabs get a 1px `border-left` separator. The rule is scoped to
  `window.background.chromium notebook > header > tabs > tab`; native
  notebooks are unaffected. Restart the browser to apply.

## Palette

GTK3, GTK4 and GTK2-light share one palette (`@define-color` names, GTK3/GTK4):

| Role | Dark | Light |
| --- | --- | --- |
| `my_base` (window) | `#121314` | `#f7f7f7` |
| `my_surface` | `#1f1f1f` | `#f8f8f8` |
| `my_surface_hi` (GTK3: `my_surface_alt`) | `#232323` | `#f3f3f3` |
| `my_border` | `#282828` | `#dbdbdb` |
| `my_fg` | `#ededed` | `#171311` |
| `my_fg_dim` | `#a0a0a0` | `#6f6f6f` |
| `my_accent` | `#fab283` | `#c9a227` |
| `my_selected` | `rgba(250,178,131,0.20)` | `rgba(201,162,39,0.22)` |
| `my_success` / `my_warning` / `my_error` | `#12c905` / `#fcd53a` / `#fc533a` | `#0a8f00` / `#9a7400` / `#c0261a` |

`gtk-2.0/gtkrc-dark` still uses an older, VS Code Dark+-style palette (window
`#101113`, foreground `#d4d4d4`, accent `#007acc`, selection `#264f78`), so
GTK2 dark applications do not match GTK3/GTK4 dark.

## Checks

```sh
scripts/check.py        # from the repository root
```

Verifies CSS/rc syntax, that every `@colour` is defined, that dark and light
stay structurally identical, that the active copies match the dark variant, and
that `switch-mode.sh` parses. It does not render anything; check visual changes
in a real GTK session.

# Maintainer: kafudz <kafudz@users.noreply.github.com>

pkgname=mytheme-gtk-theme-git
pkgver=r4.dd32a15
pkgrel=1
pkgdesc='Minimal GTK2/GTK3/GTK4 theme with dark and light variants (MyTheme, MyTheme-Light)'
arch=('any')
url='https://github.com/kafudz/GTK_THEME'
# The repository ships no LICENSE file yet; replace this once one is added.
license=('custom')
makedepends=('git' 'python')
provides=("${pkgname%-git}")
conflicts=("${pkgname%-git}")
source=("$pkgname::git+$url.git")
sha256sums=('SKIP')

pkgver() {
    cd "$pkgname"
    printf 'r%s.%s' "$(git rev-list --count HEAD)" "$(git rev-parse --short=7 HEAD)"
}

check() {
    cd "$pkgname"
    python scripts/check.py MyTheme
}

package() {
    cd "$pkgname/MyTheme"

    # GTK picks gtk-dark.css over gtk.css when a dark preference is set, and
    # gtkrc is the only file GTK2 reads. To avoid any dependency on which
    # variant the repository currently marks active, each theme directory gets
    # exactly one variant installed as gtk.css / gtkrc.
    local variant theme dest
    for variant in dark light; do
        case $variant in
            dark)  theme=MyTheme ;;
            light) theme=MyTheme-Light ;;
        esac
        dest="$pkgdir/usr/share/themes/$theme"

        install -Dm644 index.theme "$dest/index.theme"
        install -Dm644 "gtk-2.0/gtkrc-$variant" "$dest/gtk-2.0/gtkrc"
        install -Dm644 "gtk-3.0/gtk-$variant.css" "$dest/gtk-3.0/gtk.css"
        install -Dm644 "gtk-4.0/gtk-$variant.css" "$dest/gtk-4.0/gtk.css"
    done

    # The light variant is its own theme so it can be selected by name.
    sed -i \
        -e 's/^Name=MyTheme$/Name=MyTheme-Light/' \
        -e 's/^GtkTheme=MyTheme$/GtkTheme=MyTheme-Light/' \
        "$pkgdir/usr/share/themes/MyTheme-Light/index.theme"

    # Documentation and settings templates (switch-mode.sh is for per-user
    # installs and is intentionally not packaged).
    install -Dm644 README.md "$pkgdir/usr/share/doc/$pkgname/README.md"
    install -Dm644 user-config/gtk-3.0/settings.ini \
        "$pkgdir/usr/share/doc/$pkgname/examples/gtk-3.0/settings.ini"
    install -Dm644 user-config/gtk-4.0/settings.ini \
        "$pkgdir/usr/share/doc/$pkgname/examples/gtk-4.0/settings.ini"
}

# Maintainer: alteralph
pkgname=rpd-sky
pkgver=2.0.0
pkgrel=1
pkgdesc="RPD Sky - Organized task and thought management app"
arch=('x86_64')
url="https://example.com"
license=('GPL')
depends=('gtk3>=3.0' 'libxkbcommon' 'glib2')

source=()

build() {
  return 0
}

package() {
  local project_root="/home/alteralph/Documents/projects/rpd_flutter"
  local bundle_dir="$project_root/build/linux/x64/release/bundle"

  if [ ! -d "$bundle_dir" ]; then
    echo "Error: Pre-built binary not found at $bundle_dir"
    return 1
  fi

  install -d "$pkgdir/opt/$pkgname"
  cp -r "$bundle_dir"/* "$pkgdir/opt/$pkgname/"

  install -Dm644 "$project_root/linux/com.alteralph.rpdsky.desktop" \
    "$pkgdir/usr/share/applications/com.alteralph.rpdsky.desktop"
  install -Dm644 "$project_root/icon.png" \
    "$pkgdir/usr/share/pixmaps/rpd-sky.png"

  install -d "$pkgdir/usr/bin"
  ln -s "/opt/$pkgname/rpd-sky" "$pkgdir/usr/bin/rpd-sky"
}
